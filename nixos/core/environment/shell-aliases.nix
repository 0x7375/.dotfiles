{
  lib,
  config,
  pkgs,
  ...
}:

let
  tput = "${lib.getExe' pkgs.ncurses "tput"}";
  git = "${lib.getExe' pkgs.git "git"}";
in
{
  environment.shellAliases = {
    np = "${lib.getExe pkgs.nix} profile";
    ns = "${lib.getExe pkgs.nix} shell";

    svn = "${lib.getExe' pkgs.subversion "svn"} --config-dir $XDG_CONFIG_HOME/subversion";
    adb = "HOME=$XDG_DATA_HOME/android ${lib.getExe' pkgs.android-tools "adb"}";
    wget = "${lib.getExe pkgs.wget} --hsts-file=$XDG_DATA_HOME/wget-hsts";

    v = "$EDITOR";

    e = "${lib.getExe' pkgs.atool "aunpack"}";
    c = "${lib.getExe' pkgs.atool "apack"}";

    mkdir = "mkdir -vp";
    rm = "rm -v";
    cp = "cp -v";
    mv = "mv -v";

    free = "${lib.getExe' pkgs.procps "free"} -h";
    df = "${lib.getExe' pkgs.coreutils "df"} -h";
    du = "${lib.getExe' pkgs.coreutils "du"} -h";

    ffmpeg = "${lib.getExe' pkgs.ffmpeg-full "ffmpeg"} -hide_banner";

    grep = "${lib.getExe' pkgs.gnugrep "grep"} --color=always";
    ls = "ls --color --group-directories-first -h";
    ll = "${lib.getExe' pkgs.coreutils "ls"} -lha --color --group-directories-first";
    lsblk = "${lib.getExe' pkgs.util-linux "lsblk"} -o NAME,FSTYPE,SIZE,MOUNTPOINTS";
    tree = "${lib.getExe pkgs.tree} -L 4";
    diff = "${lib.getExe' pkgs.diffutils "diff"} --color";
    bc = "${lib.getExe pkgs.bc} -l";

    so = "${lib.getExe' pkgs.ncurses "clear"}; exec $SHELL";

    mount-web = "${lib.getExe pkgs.sshfs} -o gid=1000,uid=1000,noauto,_netdev,reconnect,auto_cache,ServerAliveInterval=5,ServerAliveCountMax=3 web:/www-dev/ ~/uni/web";
    unmount-web = "${lib.getExe' pkgs.fuse "fusermount"} -uz ~/uni/web";

    # make sudo work with aliases
    sudo = "sudo ";

    open = "${lib.getExe' pkgs.xdg-utils "xdg-open"}";

    gd = "${git} diff";
    gs = "${git} status";
    ga = "${git} add";
    gc = "${git} commit";

    py = "python";

    tm = "${lib.getExe pkgs.scripts.tmux-sessionizer}";

    temp = "cd $(mktemp -d)";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

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
          ${lib.getExe' pkgs.poppler-utils "pdftocairo"} -pdf "$1" "''${1%.pdf}-fixed.pdf"
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
        ${cdDotfiles "${git} pull --rebase --autostash"}
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

      vpn () {
        if [[ $# -eq 0 ]]; then
          echo "Usage: vpn <start|stop|restart|show|list> [interface(s)]"
          return 1
        fi

        action="$1"
        shift

        case "$action" in
          start|stop|restart)
            if [[ $# -eq 0 ]]; then
              echo "No interfaces specified. Please provide at least one interface."
              return 1
            fi
            for interface in "$@"; do
              sudo systemctl "$action" wg-quick-$interface.service
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
            systemctl list-unit-files 'wg-quick-*.service' | grep -v "static\|alias" | grep "wg-quick-" | awk '{print $1}' | sed 's/wg-quick-\(.*\).service/\1/' | tr '\n' ' ' | sed 's/ $/\n/'
            ;;
          *)
            echo "Invalid action. Use 'start', 'stop', 'restart', 'list' or 'show'."
            return 1
            ;;
        esac
      }

      r() {
        ${lib.getExe' pkgs.coreutils "realpath"} $(where $1);
      }

      nhv() {
        ${lib.getExe pkgs.nix} eval --json path:$FLAKE#homeConfigurations."$USER@''${2:-$HOST}".config.$1 | jq -r
      }

      nv() {
        ${lib.getExe pkgs.nix} eval --json path:$FLAKE#nixosConfigurations.''${2:-$HOST}.config.$1 | jq -r
      }

      suv() {
        [[ -L $1 ]] && {
          sudo cp "$1" "$1.bak"
          sudo rm "$1"
          sudo mv "$1.bak" "$1"
          sudo chmod 644 "$1"
        }
        sudo $EDITOR "$1"
      }

      uv() {
        [[ -L $1 ]] && {
          cp "$1" "$1.bak"
          rm "$1"
          mv "$1.bak" "$1"
          chmod 644 "$1"
        }
        $EDITOR "$1"
      }
    '';
}
