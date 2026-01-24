{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) getExe getExe';
  tput = "${getExe' pkgs.ncurses "tput"}";
  git = "${getExe' pkgs.git "git"}";
in
{
  aliases = {
    np = "nix profile";
    ns = "nix shell";
    nr = "nix repl .";

    svn = "${getExe' pkgs.subversion "svn"} --config-dir $XDG_CONFIG_HOME/subversion";
    adb = "HOME=$XDG_DATA_HOME/android ${getExe' pkgs.android-tools "adb"}";
    wget = "${getExe pkgs.wget} --hsts-file=$XDG_DATA_HOME/wget-hsts";

    v = "$EDITOR";

    extract = "${getExe' pkgs.atool "aunpack"}";
    compress = "${getExe' pkgs.atool "apack"}";

    mkdir = "mkdir -vp";
    rm = "rm -v";
    cp = "cp -v";
    mv = "mv -v";

    free = "${getExe' pkgs.procps "free"} -h";
    df = "${getExe' pkgs.coreutils "df"} -h";
    du = "${getExe' pkgs.coreutils "du"} -h";

    ffmpeg = "${getExe' pkgs.ffmpeg-full "ffmpeg"} -hide_banner";

    grep = "${getExe' pkgs.gnugrep "grep"} --color=always";
    ls = "${getExe' pkgs.coreutils "ls"} --color --group-directories-first -h";
    ll = "${getExe' pkgs.coreutils "ls"} -lha --color --group-directories-first";
    lsblk = "${getExe' pkgs.util-linux "lsblk"} -o NAME,FSTYPE,SIZE,MOUNTPOINTS";
    tree = "${getExe pkgs.tree} -L 4";
    difff = "${getExe' pkgs.diffutils "diff"} --color";
    bc = "${getExe pkgs.bc} -l";

    so = "exec $SHELL";

    mount-web = "${getExe pkgs.sshfs} -o gid=1000,uid=1000,noauto,_netdev,reconnect,auto_cache,ServerAliveInterval=5,ServerAliveCountMax=3 web:/www-dev/ ~/uni/web";
    unmount-web = "${getExe' pkgs.fuse "fusermount"} -uz ~/uni/web";

    open = "${getExe' pkgs.xdg-utils "xdg-open"}";

    py = "python";

    tm = "${getExe pkgs.scripts.tmux-sessionizer}";

    temp = "cd $(mktemp -d)";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  }
  // (lib.genAttrs [
    "diff"
    "status"
    "add"
    "commit"
    "push"
    "pull"
    "clone"
    "log"
    "branch"
    "remote"
    "reset"
    "revert"
    "restore"
    "stash"
    "switch"
    "worktree"
  ] (name: "${git} ${name}"));

  environment.shellInit =
    let
      cdDotfiles =
        string:
        # bash
        ''
          pushd ${config.me.flakeDir} >/dev/null
          ${string}
          popd >/dev/null
        '';
    in
    # bash
    ''
      blue=$(${tput} setaf 4)
      reset=$(${tput} sgr0)
      green=$(${tput} setaf 2)
      hide=$(${tput} civis)
      show=$(${tput} cnorm)
      dots="''${green}::''${reset}"

      export SUDO_PROMPT="''${dots} Password for %p: "

      fixpdf() {
          ${getExe' pkgs.poppler-utils "pdftocairo"} -pdf "$1" "''${1%.pdf}-fixed.pdf"
      }

      dotr() {
        ${cdDotfiles
          # bash
          ''
            echo -n "''${dots} Discard changes? [y/N]''${hide}"
            read -s -r -k 1 answer
            echo "$show"

            [[ $answer == "y" ]] && {
              ${git} restore .
            }
          ''
        }
      }

      dota() {
        ${cdDotfiles
          # bash
          ''
            ${git} add .;
            changes=$(${git} diff --cached --name-status | awk '{
              if ($1 ~ /^R[0-9]*/) {
                # For renames, print both old and new filenames
                print "Rename " $2 " -> " $3
              } else {
                print $1 " " $2
              }
            }' | sed 's/^A /Add /; s/^M /Update /; s/^D /Delete /');

            if [[ -z "$changes" ]]; then
              echo "''${dots} No changes to commit"
            else
              ${git} commit -m "$(printf "%s\n" "$changes")";
            fi

            ${git} pull --rebase;

            echo -n "''${dots} Push changes? [y/N]''${hide}"
            read -s -r -k 1 answer
            echo "$show"

            [[ $answer == "y" ]] && {
              ${git} push
            }
          ''
        }
      }

      dotu() {
        ${cdDotfiles ''
          if ! ${git} pull --rebase --autostash; then
            if ${git} diff --name-only --diff-filter=U | grep -q "flake.lock"; then
              local_time=$(${git} log -1 --format=%ct HEAD -- flake.lock 2>/dev/null || echo 0)
              remote_time=$(${git} log -1 --format=%ct REBASE_HEAD -- flake.lock 2>/dev/null || echo 0)
              
              if [[ $remote_time -gt $local_time ]]; then
                ${git} checkout REBASE_HEAD -- flake.lock
              else
                ${git} checkout HEAD -- flake.lock
              fi
              
              ${git} add flake.lock
              ${git} rebase --continue
            fi
          fi
        ''}
      }

      dotf() {
        ${cdDotfiles
          # bash
          ''
            ${git} add -N .
            {
              ${git} diff --color=always
              ${git} diff --cached --color=always
            } | less -R
          ''
        }
      }

      vpn() {
        if [[ $# -eq 0 ]]; then
          echo "Usage: vpn <start|stop|restart|show|list> [interface(s)]"
          return 1
        fi

        action="$1"
        shift

        # TODO: support darwin
        case "$action" in
          start|stop|restart)
            if [[ $# -eq 0 ]]; then
              echo "No interfaces specified. Please provide at least one interface."
              return 1
            fi
            for interface in "$@"; do
              if [[ $(uname) == "Darwin" ]]; then
                echo yes
              else
                sudo systemctl "$action" wg-quick-$interface.service
              fi
            done
            ;;
          show)
            if [[ $# -eq 0 ]]; then
              sudo wg show
            else
              for interface in "$@"; do
                sudo wg show $interface
              done
            fi
            ;;
          list)
            echo -n "Available WireGuard interfaces: "
            if [[ $(uname) == "Darwin" ]]; then
              echo yes
            else
              systemctl list-unit-files 'wg-quick-*.service' | grep -v "static\|alias" | grep "wg-quick-" | awk '{print $1}' | sed 's/wg-quick-\(.*\).service/\1/' | tr '\n' ' ' | sed 's/ $/\n/'
            fi
            ;;
          *)
            echo "Invalid action. Use 'start', 'stop', 'restart', 'list' or 'show'."
            return 1
            ;;
        esac
      }

      r() {
        ${getExe' pkgs.coreutils "realpath"} $(where $1);
      }

      nhv() {
        local result
        if result=$(nix eval --json path:$FLAKE#nixosConfigurations.''${2:-$HOST}.config.hjem.users.$USER.$1 2>/dev/null); then
            echo "$result" | jq -r
        else
            nix eval path:$FLAKE#nixosConfigurations.''${2:-$HOST}.config.hjem.users.$USER.$1
        fi
      }

      nv() {
          local result
          local system=nixos
          [[ $(uname) == "Darwin" ]] && system=darwin
          if result=$(nix eval --json path:$FLAKE#''${system}Configurations.''${2:-$HOST}.config.$1 2>/dev/null); then
              echo "$result" | jq -r
          else
              nix eval path:$FLAKE#''${system}Configurations.''${2:-$HOST}.config.$1
          fi
      }
    '';
}
