{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "nd";
  bashOptions = [
    "nounset"
    "pipefail"
  ];
  runtimeInputs = with pkgs; [
    coreutils
    gnutar
    nvd
    git
    nix-output-monitor
    jq
    ncurses
  ];
  text = # bash
    ''
      hide_cursor=$(tput civis)
      show_cursor=$(tput cnorm)
      green=$(tput setaf 2)
      reset=$(tput sgr0)
      tmp_dir=$(mktemp -d)
      staged_diff_file="$tmp_dir/nd-diff-staged"

      doc() {
          echo "Usage:
            nd <COMMAND> [HOST] | nd [HOST] [-- <NIX_BUILD_FLAGS>...]

          Commands:
            switch       Build, activate and make boot default (default)
            boot         Build and make boot default without activating
            test         Build and activate without making boot default
            build        Build without activating
            iso          Build ISO image
            iso-vm       Build ISO image virtual machine

          Arguments:
            HOST   Optional remote hostname to build and deploy to
            NIX_BUILD_FLAGS  Optional flags to pass to nix build"
          exit 1
      }

      log() {
          local -r dots="''${green}::''${reset}"
          local nonewline=""
          
          if [[ $1 == "-n" ]]; then
              nonewline="-n"
              shift
          fi
          echo $nonewline "$dots $1"
      }

      error() {
          local -r red=$(tput setaf 1)
          local -r reset=$(tput sgr0)
          echo "''${red}Error:''${reset} $1"
          exit 1
      }

      silent() {
          "$@" &> /dev/null
      }

      ssh_run() {
        ssh -q "''${ssh_opts[@]}" "$user@$host" -t TERM="$TERM" "$*"
      }

      try_ssh() {
        local -r user="$1"
        local -r host="$2"

        log "Testing SSH connection to ''${user}@''${host}"

        if ! silent ssh "''${ssh_opts[@]}" "$user@$host" -o ConnectTimeout=5 true; then
          error "Cannot establish SSH connection to $user@$host"
        fi
      }

      switch_configuration() {
        local -r action="$1"
        local -r result="$2"
        local -r profile="/nix/var/nix/profiles/system"
        local -a commands=()

        [[ $action != "boot" ]] && {
          commands+=("$result/bin/switch-to-configuration test")
        }

        [[ $action != "test" ]] && {
          commands+=("nix build --no-link --profile $profile $result 2> /dev/null")
          commands+=("$result/bin/switch-to-configuration boot")
        }

        for cmd in "''${commands[@]}"; do
          if [[ -n $remote_build ]]; then
            ssh_run "$cmd"
          else
            sudo bash -c "$cmd"
          fi
        done
      }

      build_config() {
        local host="$1"; shift
        local -r action="$1"; shift
        local -a extra_args=("$@")
        local build_attr="toplevel"
        local -a build_args=()

        [[ $action == "iso" ]] && build_attr="isoImage" && host="isoImg"
        [[ $action == "iso-vm" ]] && build_attr="vm" && host="isoImg"
        [[ $changing_generation -eq 1 ]] && build_args+=(--no-link)

        nom build "''${build_args[@]}" --json "''${extra_args[@]}" path:.#nixosConfigurations."$host".config.system.build."$build_attr" | jq -r '.[].outputs.out'
      }

      show_git_diff() {
        PAGER=''' git diff \
        --ignore-blank-lines \
        -U1 \
        --color \
        --no-prefix \
        --minimal \
        -- \
        '*.nix' \
        | { grep -v -E "index [0-9a-f]{7}\.\.[0-9a-f]{7}" --color=never || true; }
      }

      show_generation_diff() {
        local -r result="$1"
        local -r cmd="nix run nixpkgs#nvd diff /run/current-system $result"

        if [[ -n $remote_build ]]; then
          ssh_run "$cmd"
        else
          eval "$cmd"
        fi
      }

      cleanup() {
        local -r err_code=$?

        [[ -d .git && $err_code -ne 0 && $remote_build -ne 1 ]] && silent git reset && silent git apply --cached "$staged_diff_file"
        echo -n "$show_cursor"
        silent popd

        trap - EXIT
        exit $err_code
      }

      main() {
        local -a nd_args=()
        local -a nix_build_flags=()
        local -i found_separator=0
        local -i force_rebuild=0
        local -i changing_generation=0

        for arg in "$@"; do
          if [[ $found_separator -eq 1 ]]; then
            nix_build_flags+=("$arg")
          elif [[ $arg == "--" ]]; then
            found_separator=1
          elif [[ $arg == "-f" || $arg == "--force" ]]; then
            force_rebuild=1
          elif [[ $arg == "-h" || $arg == "--help" ]]; then
            doc
          else
            nd_args+=("$arg")
          fi
        done

        [[ ''${#nd_args[@]} -eq 0 ]] && nd_args+=("switch")
        [[ ''${#nd_args[@]} -gt 2 ]] && doc

        local action
        case ''${nd_args[0]} in
          switch|boot|test|build|iso-vm|iso)
            action="''${nd_args[0]}"
            ;;
          *)
            nd_args=("switch" "''${nd_args[0]}")
            action="switch"
            ;;
        esac
        local -r action nd_args

        [[ $action == "switch" || $action == "boot" || $action == "test" ]] && changing_generation=1

        trap cleanup INT ERR EXIT

        silent pushd ${config.me.flakeDir}

        local user; user=$(whoami)
        local host=''${HOST:-$(hostname)}
        local remote_build=

        if [[ ''${#nd_args[@]} -eq 2 ]]; then
          [[ $action == "iso" || $action == "iso-vm" || $action == "build" ]] && error "$action doesn't take a host"

          host=''${nd_args[1]}
          user="root"
          remote_build=1

          local -r user host remote_build

          ssh_opts=("-o" "ControlMaster=auto" "-o" "ControlPath=$tmp_dir/ssh-nd-$host" "-o" "ControlPersist=60")
          try_ssh "$user" "$host"
        fi


        local -r state_dir="''${HOME}/.local/state/nd"
        mkdir -p "$state_dir"

        local cache_action=$action
        [[ $action != iso && $action != iso-vm ]] && cache_action=nixos

        local -r hash_file="''${state_dir}/''${host}-''${cache_action}-hash"
        local -r result_file="''${state_dir}/''${host}-''${cache_action}-result"

        local last_rebuild_hash=""
        local result=""

        [[ -f $result_file ]] && result=$(< "$result_file")
        [[ -f $hash_file ]] && last_rebuild_hash=$(< "$hash_file")

        local -ra exclusion_patterns=("result" "*.qcow2" "nvim" ".git")
        local -a excluded=()
        for pattern in "''${exclusion_patterns[@]}"; do
            excluded+=(--exclude "$pattern")
        done

        local -r current_hash=$(tar --sort=name --mtime='1970-01-01 00:00:00' --owner=0 --group=0 -cf - "''${excluded[@]}" . | sha256sum | cut -d' ' -f1)

        if [[ $force_rebuild -eq 1 || $last_rebuild_hash != "$current_hash" || -z $result ]]; then
          [[ $changing_generation -eq 1 && -z $remote_build && -d .git ]] && {
            git add -N .
            log "Showing changes"
            show_git_diff
            git diff --cached > "$staged_diff_file"
            git add .
          }

          log "Building configuration";
          result=$(build_config "$host" "$action" "''${nix_build_flags[@]}")

          echo "$result" > "$result_file"
          echo "$current_hash" > "$hash_file"

          if [[ -n $remote_build ]]; then
            # prevent garbage collection of the closure
            silent sudo nix-store --realise "$result" --add-root "/nix/var/nix/gcroot/$host-nixos"

            log "Copying closure to $host"
            env "NIX_SSHOPTS=-q ''${ssh_opts[*]}" nix-copy-closure --to "$user"@"$host" "$result"
          fi

          if [[ $changing_generation -eq 1 ]]; then
            log "Comparing configurations"
            show_generation_diff "$result"
          fi
        else
          log "No changes detected, skipping build"
        fi

        case $action in
          iso) log "Iso image built, can be found in ''${green}./result/iso''${reset}"; exit ;;
          iso-vm) log "Iso image vm built, run with ''${green}./result/bin/run-iso-vm''${reset}"; exit ;;
          build) log "Configuration built, can be found in ''${green}./result''${reset}"; exit ;;
          *) ;;
        esac

        case $action in
          switch|test) log -n "Activate the configuration?" ;;
          boot) log -n "Make this configuration the boot default?" ;;
          *) ;;
        esac

        echo -n " [y/N]$hide_cursor"
        read -s -r -n 1 answer
        echo "$show_cursor"

        if [[ $answer == "y" ]]; then
          echo "yes"
          [[ $action != "boot" ]] && log "Switching to configuration"
          switch_configuration "$action" "$result"
        else
          echo "no"
        fi

        cleanup
      }

      main "$@"
    '';
}
