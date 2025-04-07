{ pkgs, ... }:

{
  home.file.".config/zsh/widgets.zsh" = {
    force = true;
    mutable = true;
    text = # bash
      ''
        function lfcd() {
            export LF_CD_FILE=/var/tmp/.lfcd-$$

            command ${pkgs.lf}/bin/lf "$@"

            # remove mounted archives
           ${pkgs.gawk}/bin/awk '$1 == "archivemount" { print $2 }' /etc/mtab | while read -r mntdir
            do
              umount "$mntdir"
              rmdir "$mntdir"
              unset LF_CD_FILE
            done

            # handle cd to last directory
            if [ -s "$LF_CD_FILE" ]; then
                local DIR="$(${pkgs.coreutils-full}/bin/realpath "$(${pkgs.coreutils-full}/bin/cat "$LF_CD_FILE")")"
                cd $DIR
                \rm "$LF_CD_FILE"
            fi
            unset LF_CD_FILE
        }
        # don't use a widget because of https://github.com/gokcehan/lf/issues/585

        function tmux-sessionizer-widget {
            command ${pkgs.scripts.tmux-sessionizer}/bin/tmux-sessionizer
            zle reset-prompt
        }
        zle -N tmux-sessionizer-widget

        function prepend-sudo {
            if [[ $BUFFER != "sudo "* ]]; then
                BUFFER="sudo $BUFFER"; CURSOR+=5
                zle reset-prompt
            fi
        }
        zle -N prepend-sudo

        autoload -U edit-command-line
        zle -N edit-command-line
      '';
  };
}
