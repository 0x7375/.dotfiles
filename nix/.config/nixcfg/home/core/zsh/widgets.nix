{ pkgs, ... }:

{
  xdg.configFile."zsh/widgets.zsh".text = # bash
    ''
      function lf() {
          export LF_CD_FILE=/var/tmp/.lfcd-$$

          command ${pkgs.lf}/bin/lf "$@"

          # remove mounted archives
          ${pkgs.gawk}/bin/awk '$1 == "archivemount" { print $2 }' /etc/mtab | while read -r mntdir
          do
            umount "$mntdir" -l
            rmdir "$mntdir"
          done

          # handle cd to last directory
          if [ -s "$LF_CD_FILE" ]; then
              cd "$(< "$LF_CD_FILE")"
              \rm "$LF_CD_FILE"
          fi
          unset LF_CD_FILE
      }
      # don't use a widget because of https://github.com/gokcehan/lf/issues/585

      autoload -U edit-command-line
      zle -N edit-command-line

      fzf-history-widget() {
        local -r selected=$(fc -rl 1 | fzf --height 40% --reverse --query="$LBUFFER")
        
        if [ -n "$selected" ]; then
          local num=$(echo "$selected" | awk '{print $1}')
          zle vi-fetch-history -n $num
        fi
        zle reset-prompt
      }
      zle -N fzf-history-widget

    '';
}
