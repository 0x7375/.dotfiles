{ config, pkgs, ... }:

let
  tput = "${pkgs.ncurses}/bin/tput";
in
{
  environment.shellAliases =
    let
      cdDotfiles =
        string:
        # bash
        ''
          pushd ${config.me.dotfilesDir} >/dev/null
          ${string}
          popd >/dev/null
        '';
      git = "${pkgs.git}/bin/git";
    in
    {
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

      e = "${pkgs.atool}/bin/aunpack";
      c = "${pkgs.atool}/bin/apack";

      mkdir = "mkdir -vp";
      rm = "rm -v";
      cp = "cp -v";
      mv = "mv -v";

      free = "${pkgs.procps}/bin/free -h";
      df = "${pkgs.coreutils}/bin/df -h";
      du = "${pkgs.coreutils}/bin/du -h";

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

      sudo = "sudo ";

      dota =
        cdDotfiles
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
            ${git} commit -m "$(printf "%s\n" "$changes")";
            ${git} pull --rebase;
            ${git} push
          '';
      dotu = cdDotfiles "${git} pull --rebase";
      dotf =
        cdDotfiles
          # bash
          ''
            {
              ${git} diff --color=always
              ${git} ls-files --others --exclude-standard \
              | xargs -I{} ${git} diff --color=always --no-index /dev/null {}
            } | less -R
          '';
      dotr =
        cdDotfiles
          # bash
          ''
            green=$(${tput} setaf 2)
            reset=$(${tput} sgr0)
            hide=$(${tput} civis)
            show=$(${tput} cnorm)

            echo "''${green}>''${reset}Discard dotfiles changes?"
            echo -n "[y/N]''${hide}"
            read -s -r -n 1 answer

            [[ $answer == "y" ]] && {
              ${git} restore .
            }
            echo "$show"
          '';

      gd = "${git} diff";
      gds = "${git} diff --staged";
      gs = "${git} status --short";
      gss = "${git} status";
      ga = "${git} add";
      gc = "${git} commit";
      gca = "${git} commit --amend";
      gcm = "${git} commit -m";
      gk = "${git} checkout";
      gh = "${git} stash";

      clip = "${pkgs.xclip}/bin/xclip -sel clip";

      py = "python";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

  environment.shellInit = # bash
    ''
      blue=$(${tput} setaf 4)
      reset=$(${tput} sgr0)
      export SUDO_PROMPT="''${blue}[sudo] password for %p:''${reset} "

      vpn () {
          if [ $# -eq 0 ]; then
              echo "Usage: vpn <start|stop|restart|show|list> [interface(s)]"
              return 1
          fi

          action="$1"
          shift

          case "$action" in
              start|stop|restart)
                  if [ $# -eq 0 ]; then
                      echo "No interfaces specified. Please provide at least one interface."
                      return 1
                  fi
                  for interface in "$@"; do
                      sudo systemctl "$action" wg-quick-$interface.service
                  done
                  ;;
              show)
                  if [ $# -eq 0 ]; then
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
        ${pkgs.coreutils}/bin/nohup $1 > /dev/null &
      }

      tm() {
        ${pkgs.scripts.tmux-sessionizer}/bin/tmux-sessionizer $1
      }

      suv() {
        [[ -L "$1" ]] && {
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
        [[ -L "$1" ]] && {
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
