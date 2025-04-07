{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "nd";
  runtimeInputs = with pkgs; [
    home-manager
    coreutils
    nh
    git
    nvd
    nix-output-monitor
    jq
  ];
  text = # bash
    ''
      set +o errexit

      doc() {
          echo "Usage:
            nd <COMMAND> [HOST] [-- <NIX_BUILD_FLAGS>...]

          Commands:
            os     Rebuild nixos configuration
            home   Rebuild home-manager configuration
            all    Rebuild nixos configuration with home-manager as a module (default)

          Arguments:
            HOST   Optional remote hostname to build and deploy to"
            NIX_BUILD_FLAGS  Optional flags to pass to nix build
          exit 1
      }

      silent() {
          "$@" >/dev/null 2>&1
      }

      ssh_run() {
        local user=$1
        local cmd=$2
        local interactive=$3
        local silent=''${4:-}

        ''${silent:+silent} ssh -q "$user@$host" ''${interactive:+-t TERM=$TERM} "$cmd"
      }

      try_ssh() {
        local msg="Error: Cannot establish SSH connection to"
        if ! silent ssh "$user@$host" -o ConnectTimeout=5 true; then
          echo "$msg $user@$host"
          exit 1
        fi
        if ! silent ssh "$root@$host" -o ConnectTimeout=5 true; then
          echo "$msg $root@$host"
          exit 1
        fi
      }

      activate_config() {
        if [[ $mode = "home" ]]; then
          local cmd="$result/activate"
          if [[ -n $remote ]]; then
            ssh_run "$user" "$cmd" 1
          else
            eval "$cmd"
          fi
        else
          local cmd1=(nix-env -p /nix/var/nix/profiles/system --set "$result")
          local cmd2=("$result"/bin/switch-to-configuration switch)

          if [[ -n $remote ]]; then
            ssh_run "$root" "''${cmd1[*]}" 1
            ssh_run "$root" "''${cmd2[*]}" 1
          else
            sudo "''${cmd1[@]}"
            sudo "''${cmd2[@]}"
          fi
        fi
      }

      build_config() {
        local extra_args=("$@")
        if [[ $mode = "all" ]]; then
          nom build --no-link --json "''${extra_args[@]}" path:.#nixosConfigurations."$host".config.system.build.toplevel | jq -r '.[].outputs.out'
        elif [[ $mode = "home" ]]; then
          nom build --no-link --json "''${extra_args[@]}" path:.#homeConfigurations."$user"@"$host".activationPackage | jq -r '.[].outputs.out'
        else
          nom build --no-link --json "''${extra_args[@]}" path:.#nixosWithoutHomeConfigurations."$host".config.system.build.toplevel | jq -r '.[].outputs.out'
        fi
      }

      add_gc_root() {
        local result=$1
        if [[ -n $remote ]]; then
          sudo nix-store --realise "$result" --add-root "/nix/var/nix/gcroot/$remote-$mode"
        fi
      }

      get_last_commited_gen() {
        git log --oneline | grep "$mode:" | head -n 1 | cut -d\  -f 3
      }

      show_git_diff() {
        PAGER=''' git diff \
        --ignore-blank-lines \
        --staged \
        -U1 \
        --color \
        --no-prefix \
        --minimal \
        -- \
        '*.nix' \
        "''${exclude_patterns[@]}" \
        | { grep -v -E "index [0-9a-f]{7}\.\.[0-9a-f]{7}" --color=never || true; }
      }

      get_current_gen() {
        local cmd
        if [[ $mode == "home" ]]; then
          cmd="readlink ~/.local/state/nix/profiles/home-manager | cut -d- -f 3"
          if [[ -n $remote ]]; then
            ssh_run "$user" "$cmd" 0
          else
            eval "$cmd"
          fi
        else
          cmd="readlink /nix/var/nix/profiles/system | cut -d- -f 2" 
          if [[ -n $remote ]]; then
            ssh_run "$root" "$cmd" 0
          else
            eval "$cmd"
          fi
        fi
      }

      get_gen_metadata() {
        local os_cmd="nixos-version | cut -d\  -f 1"
        local home_cmd="home-manager --version"
        local version
        if [[ -n $remote ]]; then
          if [[ $mode = "home" ]]; then
            version=$(ssh_run "$user" "$home_cmd" 0)
          else
            version=$(ssh_run "$user" "$os_cmd" 0)
          fi
        else
          if [[ $mode = "home" ]]; then
            version=$(eval "$home_cmd")
          else
            version=$(eval "$os_cmd")
          fi
        fi
        current_generation=$(get_current_gen)
        current_date=$(date "+%Y-%m-%d %H:%m:%S")

        echo "$mode: $current_generation $current_date $version"
      }

      show_generation_diff() {
        local cmd
        if [[ $mode = "home" ]]; then
          cmd="nix run nixpkgs#nvd diff ~/.local/state/nix/profiles/home-manager $result"
          if [[ -n $remote ]]; then
            ssh_run "$user" "$cmd" 1
          else
            eval "$cmd"
          fi
        else
          cmd="nix run nixpkgs#nvd diff /run/current-system $result"
          if [[ -n $remote ]]; then
            ssh_run "$root" "$cmd" 1
          else
            eval "$cmd"
          fi
        fi
      }

      cleanup() {
        echo -n "$CLR_SHOW"
        silent popd; exit
      }

      restore() {
        git restore --staged .
      }

      main() {
        [[ $# -eq 0 ]] && set -- "all"

        local nd_args=()
        local nix_build_flags=()
        local found_separator=0
        
        for arg in "$@"; do
          if [[ $found_separator -eq 1 ]]; then
            nix_build_flags+=("$arg")
          elif [[ $arg == "--" ]]; then
            found_separator=1
          else
            nd_args+=("$arg")
          fi
        done

        case ''${nd_args[0]} in
          os|home|all) ;;
          *) doc ;;
        esac

        export GIT_DIR=.nix-git

        silent pushd ${config.me.flakeDir}

        CLR_RESET=$'\e[0m'
        CLR_GREEN=$'\e[32m'
        CLR_HIDE=$'\e[?25l'
        CLR_SHOW=$'\e[?25h'
        GREEN_ARROW="''${CLR_GREEN}>''${CLR_RESET}"

        trap cleanup INT ERR

        exclude_patterns=()
        mode="''${nd_args[0]}"
        root="root"

        user=$(whoami)

        if [[ ''${#nd_args[@]} -eq 2 ]]; then
          host=''${nd_args[1]}
          remote=''${nd_args[1]}

          try_ssh
        else
          host=$(</etc/hostname)
          remote=""
        fi

        if [[ $mode == "home" ]]; then
          exclude_patterns=(":^nixos/*" ":^*/nixos/*" ":^configuration.nix" ":^*/configuration.nix" ":^hardware.nix" ":^*/hardware.nix")
        elif [[ $mode == "os" ]]; then
          exclude_patterns=(":^home/*" ":^*/home/*" ":^*/home.nix" ":^home.nix")
        fi

        git add . -- "''${exclude_patterns[@]}"
        show_git_diff

        echo "$GREEN_ARROW Building configuration";
        result=$(build_config "''${nix_build_flags[@]}")
        add_gc_root "$result"

        if [[ -n $remote ]]; then
          silent env "NIX_SSHOPTS=-q" nix-copy-closure --to "$user"@"$host" "$result"
        fi
        
        echo "$GREEN_ARROW Comparing changes"
        show_generation_diff

        echo "$GREEN_ARROW Apply the config?"
        echo -n "[y/N]$CLR_HIDE"
        read -s -r -n 1 answer
        echo "$CLR_SHOW"

        if [[ $answer == "y" ]]; then
          echo "yes"
          echo "$GREEN_ARROW Activating configuration"
          activate_config

          if [[ $(get_current_gen) != $(get_last_commited_gen) && -n $(show_git_diff) && -z $remote ]]; then
            changes=$(git diff --cached --name-status | awk '{
              if ($1 ~ /^R[0-9]*/) {
                # For renames, print both old and new filenames
                print "Rename " $2 " -> " $3
              } else {
                print $1 " " $2
              }
            }' | sed 's/^A /Add /; s/^M /Update /; s/^D /Delete /');
            metadata=$(get_gen_metadata)
            commit_message=$(printf "%s\n\n%s" "$metadata" "$changes")
            git commit -m "$commit_message"
          else
            restore
          fi
        else
          echo "no"
          restore
        fi

        cleanup
      }

      main "$@"
    '';
}
