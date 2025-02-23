{ config, pkgs, ... }:

{
  environment.shellAliases =
    let
      dotfiles = "~/.dotfiles";
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
      lf = "lfcd";
      connect-monitor = "while true; do sleep 0.5; ${pkgs.autorandr}/bin/autorandr --change > /dev/null; done";
      v = "$EDITOR";
      please = "sudo $(fc -ln -1)";
      dot = "${pkgs.git}/bin/git -C ${dotfiles}";
      ngit = "GIT_DIR=.nix-git ${pkgs.git}/bin/git";
      da = # bash
        ''
          ${pkgs.git}/bin/git -C ${dotfiles} add .;
          changes=$(${pkgs.git}/bin/git -C ${dotfiles} diff --cached --name-status | awk '{
            if ($1 ~ /^R[0-9]*/) {
              # For renames, print both old and new filenames
              print "Rename " $2 " -> " $3
            } else {
              print $1 " " $2
            }
          }' | sed 's/^A /Add /; s/^M /Update /; s/^D /Delete /');
          ${pkgs.git}/bin/git -C ${dotfiles} commit -m "$(printf "%s\n" "$changes")";
          ${pkgs.git}/bin/git -C ${dotfiles} pull --rebase;
          ${pkgs.git}/bin/git -C ${dotfiles} push
        '';
      du = "${pkgs.git}/bin/git -C ${dotfiles} pull --rebase";
      df = "${pkgs.git}/bin/git -C ${dotfiles} diff";

      s = "${pkgs.systemd}/bin/systemctl";

      e = "${pkgs.atool}/bin/aunpack";
      c = "${pkgs.atool}/bin/apack";

      mkdir = "mkdir -vp";
      rm = "rm -v";
      cp = "cp -v";
      mv = "mv -v";
      free = "${pkgs.procps}/bin/free -m";
      grep = "${pkgs.gnugrep}/bin/grep --color=always";
      ls = "ls --color --group-directories-first";
      ll = "${pkgs.coreutils}/bin/ls -lha --color --group-directories-first";
      lsblk = "${pkgs.util-linux}/bin/lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINTS";
      tree = "${pkgs.tree}/bin/tree -L 4";
      diff = "${pkgs.diffutils}/bin/diff --color";
      pk = "${pkgs.procps}/bin/pkill";

      so = "${pkgs.ncurses}/bin/clear; exec $SHELL";

      mount-web = "${pkgs.sshfs}/bin/sshfs -o gid=1000,uid=1000,noauto,_netdev,reconnect,auto_cache,ServerAliveInterval=5,ServerAliveCountMax=3 web:/www-dev/ ~/uni/web";
      unmount-web = "${pkgs.fuse}/bin/fusermount -uz ~/uni/web";

      sudo = "sudo ";

      gd = "${pkgs.git}/bin/git diff";
      gds = "${pkgs.git}/bin/git diff --staged";
      gs = "${pkgs.git}/bin/git status --short";
      gss = "${pkgs.git}/bin/git status";
      ga = "${pkgs.git}/bin/git add";
      gc = "${pkgs.git}/bin/git commit";
      gca = "${pkgs.git}/bin/git commit --amend";
      gcm = "${pkgs.git}/bin/git commit -m";
      gk = "${pkgs.git}/bin/git checkout";
      gh = "${pkgs.git}/bin/git stash";

      clip = "${pkgs.xclip}/bin/xclip -sel clip";

      py = "${pkgs.python3}/bin/python";
      dev = "${pkgs.nix}/bin/nix develop -c ${pkgs.zsh}/bin/zsh";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

  environment.shellInit = # bash
    ''
      blue=$(${pkgs.ncurses}/bin/tput setaf 4)
      reset=$(${pkgs.ncurses}/bin/tput sgr0)
      export SUDO_PROMPT="''${blue}[sudo] password for %p:''${reset} "

      vpn () {
          if [ $# -lt 2 ]; then
              echo "Usage: vpn <start|stop|restart> <interface(s)>"
              return 1
          fi

          action="$1"
          shift

          case "$action" in
              start|stop|restart)
                  for interface in "$@"; do
                      sudo systemctl "$action" wg-quick-$interface.service
                  done
                  ;;
              *)
                  echo "Invalid action. Use 'start', 'stop', or 'restart'."
                  return 1
                  ;;
          esac
      }

      r() {
        ${pkgs.coreutils}/bin/realpath $(where $1);
      }

      nhv() {
        ${pkgs.nix}/bin/nix eval --json $FLAKE#homeConfigurations."$USER@''${2:-$HOST}".config.$1 | jq
      }

      nv() {
        ${pkgs.nix}/bin/nix eval --json $FLAKE#nixosConfigurations.''${2:-$HOST}.config.$1 | jq
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
