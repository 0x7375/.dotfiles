{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "nd";
  runtimeInputs = with pkgs; [
    home-manager
    coreutils
    gnutar
    nh
    git
    nvd
    nix-output-monitor
    jq
    ncurses
  ];
  text = # bash
    ''
      # disabled since we handle errors via trap
      set +o errexit

      HIDE_CURSOR=$(tput civis)
      SHOW_CURSOR=$(tput cnorm)

      doc() {
          echo "Usage:
            nd <COMMAND> [HOST] | nd [HOST] [-- <NIX_BUILD_FLAGS>...]

          Commands:
            os     Rebuild nixos configuration (default)
            home   Rebuild home-manager configuration

          Arguments:
            HOST   Optional remote hostname to build and deploy to
            NIX_BUILD_FLAGS  Optional flags to pass to nix build"
          exit 1
      }

      log() {
          local -r GREEN=$(tput setaf 2)
          local -r RED=$(tput setaf 1)
          local -r RESET=$(tput sgr0)
          local -r DOTS="''${GREEN}::''${RESET}"
          local nonewline=""
          
          if [[ "$1" == "-n" ]]; then
              nonewline="-n"
              shift
          fi
          echo $nonewline "$DOTS $1"
      }

      log_error() {
          local -r RED=$(tput setaf 1)
          local -r RESET=$(tput sgr0)
          echo "''${RED}Error:''${RESET} $1"
      }

      silent() {
          "$@" >/dev/null 2>&1
      }

      ssh_run() {
        local -r CMD=$1
        local -r INTERACTIVE=$2

        ssh -q "$user@$host" ''${INTERACTIVE:+-t TERM=$TERM} "$CMD"
      }

      try_ssh() {
        local -r USER="$1"
        local -r HOST="$2"

        log "Testing SSH connection to ''${USER}@''${HOST}"

        if ! silent ssh "$USER@$HOST" -o ConnectTimeout=5 true; then
          log_error "Cannot establish SSH connection to $USER@$HOST"
          exit 1
        fi
      }

      activate_config() {
        if [[ $MODE = "home" ]]; then
          local -r CMD="$result/activate"
          if [[ -n $remote_build ]]; then
            ssh_run "$CMD" 1
          else
            eval "$CMD"
          fi
        else
          local set_current_gen_cmd=(nix-env -p /nix/var/nix/profiles/system --set "$result")
          local switch_to_configuration_cmd=("$result"/bin/switch-to-configuration switch)

          if [[ -n $remote_build ]]; then
            ssh_run "''${set_current_gen_cmd[*]}" 1
            ssh_run "''${switch_to_configuration_cmd[*]}" 1
          else
            sudo "''${set_current_gen_cmd[@]}"
            sudo "''${switch_to_configuration_cmd[@]}"
          fi
        fi
      }

      build_config() {
        local extra_args=("$@")
        if [[ $MODE = "os" ]]; then
          nom build --no-link --json "''${extra_args[@]}" path:.#nixosConfigurations."$host".config.system.build.toplevel | jq -r '.[].outputs.out'
        else
          nom build --no-link --json "''${extra_args[@]}" path:.#homeConfigurations."$HM_USER"@"$host".activationPackage | jq -r '.[].outputs.out'
        fi
      }

      get_last_commited_gen() {
        git log --oneline | grep "$MODE:" | head -n 1 | cut -d\  -f 3
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
        if [[ $MODE == "home" ]]; then
          cmd="readlink ~/.local/state/nix/profiles/home-manager | cut -d- -f 3"
        else
          cmd="readlink /nix/var/nix/profiles/system | cut -d- -f 2" 
        fi

        if [[ -n $remote_build ]]; then
          ssh_run "$cmd" 0
        else
          eval "$cmd"
        fi
      }

      get_gen_metadata() {
        local cmd
        if [[ $MODE = "home" ]]; then
          cmd="home-manager --version"
        else
          cmd="nixos-version | cut -d\  -f 1"
        fi

        local version
        if [[ -n $remote_build ]]; then
          version=$(ssh_run "$cmd" 0)
        else
          version=$(eval "$cmd")
        fi

        local -r current_generation=$(get_current_gen)
        local -r current_date=$(date "+%Y-%m-%d %H:%m:%S")

        echo "$MODE: $current_generation $current_date $version"
      }

      show_generation_diff() {
        local cmd
        if [[ $MODE = "home" ]]; then
          cmd="nix run nixpkgs#nvd diff ~/.local/state/nix/profiles/home-manager $result"
        else
          cmd="nix run nixpkgs#nvd diff /run/current-system $result"
        fi

        if [[ -n $remote_build ]]; then
          ssh_run "$cmd" 1
        else
          eval "$cmd"
        fi
      }

      cleanup() {
        GIT_DIR="$OLD_GIT_DIR"
        git restore --staged .
        echo -n "$SHOW_CURSOR"
        silent popd; exit
      }

      main() {
        local nd_args=()
        local nix_build_flags=()
        local found_separator=0
        local force_rebuild=0
        
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

        local -r DEFAULT_MODE="os"
        [[ ''${#nd_args[@]} -eq 0 ]] && nd_args+=("$DEFAULT_MODE")

        # assume first argument is the host if it is not a command
        if [[ ''${nd_args[0]} != "os" && ''${nd_args[0]} != "home" ]]; then
          nd_args=("$DEFAULT_MODE" "''${nd_args[0]}")
        fi

        case ''${nd_args[0]} in
          os|home) ;;
          *) doc ;;
        esac

        local -r OLD_GIT_DIR="''${GIT_DIR:-}"
        export GIT_DIR=.nix-git

        trap cleanup INT ERR

        silent pushd ${config.me.flakeDir}

        local -r MODE="''${nd_args[0]}"
        local -r HM_USER=''${USER:-$(whoami)}

        local user; user=$(whoami)
        local host=
        local remote_build=

        if [[ ''${#nd_args[@]} -eq 2 ]]; then
          host=''${nd_args[1]}
          user="root"
          remote_build=1

          local -r user host remote_build

          try_ssh "$user" "$host"
        else
          host=$(</etc/hostname)
        fi

        local exclude_patterns
        if [[ $MODE == "home" ]]; then
          exclude_patterns=(":^nixos/*" ":^*/nixos/*" ":^configuration.nix" ":^*/configuration.nix" ":^hardware.nix" ":^*/hardware.nix" ":^disko.nix" ":^*/disko.nix")
          local exclude_patterns -r
        fi

        local -r STATE_DIR="''${HOME}/.local/state/nd"
        mkdir -p "$STATE_DIR"

        local -r HASH_FILE="''${STATE_DIR}/''${host}-''${MODE}-hash"
        local -r RESULT_FILE="''${STATE_DIR}/''${host}-''${MODE}-result"

        local last_rebuild_hash=""
        local result=""
        [[ -f "$RESULT_FILE" ]] && result=$(< "$RESULT_FILE")

        [[ -f "$HASH_FILE" ]] && last_rebuild_hash=$(< "$HASH_FILE")
        tar -cf - --exclude=''${GIT_DIR} . | sha256sum | cut -d\  -f 1 > "$HASH_FILE"

        if [[ $force_rebuild -eq 1 || $last_rebuild_hash != $(< "$HASH_FILE") || -z $result ]]; then
          git add . -- "''${exclude_patterns[@]}"

          [[ -z $remote_build ]] && {
            log "Showing changes since last commit"
            show_git_diff
          }
          log "Building configuration";
          result=$(build_config "''${nix_build_flags[@]}")

          echo "$result" > "$RESULT_FILE"

          if [[ -n $remote_build ]]; then
            # prevent garbage collection of the closure
            silent sudo nix-store --realise "$result" --add-root "/nix/var/nix/gcroot/$remote_build-$MODE"

            log "Copying closure to $host"
            env "NIX_SSHOPTS=-q" nix-copy-closure --to "$user"@"$host" "$result"
          fi

          log "Comparing configurations"
          show_generation_diff
        else
          log "No changes detected, skipping build"
        fi

        log -n "Activate the configuration? [y/N]$HIDE_CURSOR"
        read -s -r -n 1 answer
        echo "$SHOW_CURSOR"

        if [[ $answer == "y" ]]; then
          echo "yes"
          log "Activating configuration"
          activate_config

          if [[ $(get_current_gen) != $(get_last_commited_gen) && -n $(show_git_diff) && -z $remote_build ]]; then
            log "Committing changes"
            local -r CHANGES=$(git diff --cached --name-status | awk '{
              if ($1 ~ /^R[0-9]*/) {
                # For renames, print both old and new filenames
                print "Rename " $2 " -> " $3
              } else {
                print $1 " " $2
              }
            }' | sed 's/^A /Add /; s/^M /Update /; s/^D /Delete /');
            local -r METADATA=$(get_gen_metadata)
            local -r COMMIT_MSG=$(printf "%s\n\n%s" "$METADATA" "$CHANGES")
            git commit -m "$COMMIT_MSG"
          fi
        else
          echo "no"
        fi

        cleanup
      }

      main "$@"
    '';
}
