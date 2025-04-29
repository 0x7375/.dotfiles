{ config, pkgs, ... }:

let
  tput = "${pkgs.ncurses}/bin/tput";
  git = "${pkgs.git}/bin/git";
in
{
  environment.shellAliases = {
    nr = "${pkgs.nix}/bin/nix run";
    np = "${pkgs.nix}/bin/nix profile";
    nb = "${pkgs.nix}/bin/nix build";
    ns = "${pkgs.nix}/bin/nix shell";
    ne = "${pkgs.nix}/bin/nix eval";

    svn = "${pkgs.subversion}/bin/svn --config-dir $XDG_CONFIG_HOME/subversion";
    adb = "HOME=$XDG_DATA_HOME/android ${pkgs.android-tools}/bin/adb";
    wget = "${pkgs.wget}/bin/wget --hsts-file=$XDG_DATA_HOME/wget-hsts";

    l = "${config.services.locate.package}/bin/locate -d ~/.cache/locate.db";
    lu = "${config.services.locate.package}/bin/updatedb --output=/home/${config.me.user}/.cache/locate.db";

    t = "history -D | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $2 }'";
    v = "$EDITOR";
    please = "sudo $(fc -ln -1)";

    s = "${pkgs.systemd}/bin/systemctl";
    j = "${pkgs.systemd}/bin/journalctl";

    e = "${pkgs.atool}/bin/aunpack";
    c = "${pkgs.atool}/bin/apack";

    mkdir = "mkdir -vp";
    rm = "rm -v";
    cp = "cp -v";
    mv = "mv -v";

    free = "${pkgs.procps}/bin/free -h";
    df = "${pkgs.coreutils}/bin/df -h";
    du = "${pkgs.coreutils}/bin/du -h";

    ffmpeg = "${pkgs.ffmpeg}/bin/ffmpeg -hide_banner";

    grep = "${pkgs.gnugrep}/bin/grep --color=always";
    ls = "ls --color --group-directories-first";
    ll = "${pkgs.coreutils}/bin/ls -lha --color --group-directories-first";
    lsblk = "${pkgs.util-linux}/bin/lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINTS";
    tree = "${pkgs.tree}/bin/tree -L 4";
    diff = "${pkgs.diffutils}/bin/diff --color";
    pk = "${pkgs.procps}/bin/pkill";
    bc = "${pkgs.bc}/bin/bc -l";

    so = "${pkgs.ncurses}/bin/clear; exec $SHELL";

    mount-web = "${pkgs.sshfs}/bin/sshfs -o gid=1000,uid=1000,noauto,_netdev,reconnect,auto_cache,ServerAliveInterval=5,ServerAliveCountMax=3 web:/www-dev/ ~/uni/web";
    unmount-web = "${pkgs.fuse}/bin/fusermount -uz ~/uni/web";

    # make sudo work with aliases
    sudo = "sudo ";

    open = "${pkgs.xdg-utils}/bin/xdg-open";

    gd = "${git} diff";
    gds = "${git} diff --staged";
    gs = "${git} status --short";
    gss = "${git} status";
    ga = "${git} add";
    gc = "${git} commit";
    gca = "${git} commit --amend";
    gk = "${git} checkout";
    gh = "${git} stash";

    clip = "${pkgs.xclip}/bin/xclip -sel clip";

    py = "python";

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
        ${pkgs.coreutils}/bin/realpath $(where $1);
      }

      nhv() {
        ${pkgs.nix}/bin/nix eval --json path:$FLAKE#homeConfigurations."$USER@''${2:-$HOST}".config.$1 | jq -r
      }

      nv() {
        ${pkgs.nix}/bin/nix eval --json path:$FLAKE#nixosConfigurations.''${2:-$HOST}.config.$1 | jq -r
      }

      d() {
        ${pkgs.coreutils}/bin/nohup $1 > /dev/null 2>&1 &
      }

      tm() {
        ${pkgs.scripts.tmux-sessionizer}/bin/tmux-sessionizer $1
      }

      suv() {
        [[ -L $1 ]] && {
          sudo cp "$1" "$1.bak"
          sudo rm "$1"
          sudo mv "$1.bak" "$1"
          sudo chmod 644 "$1"
          sudo $EDITOR "$1"
        } || {
          echo "Not a symlink"
        }
      }

      uv() {
        [[ -L $1 ]] && {
          cp "$1" "$1.bak"
          rm "$1"
          mv "$1.bak" "$1"
          chmod 644 "$1"
          $EDITOR "$1"
        } || {
          echo "Not a symlink"
        }
      }
    '';
}
