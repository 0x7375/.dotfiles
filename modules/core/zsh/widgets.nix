{ lib, pkgs, ... }:

{
  hj.xdg.config.files."zsh/widgets.zsh".text = # bash
    ''
      function lf() {
          export LF_CD_FILE=/var/tmp/.lfcd-$$

          command ${lib.getExe pkgs.lf} "$@"

          # remove mounted archives
          mount | ${lib.getExe' pkgs.gawk "awk"} '/archivemount/ { print $3 }' | while read -r mntdir
          do
              if [[ "$OSTYPE" == "darwin"* ]]; then
                  umount "$mntdir"
              else
                  umount "$mntdir" -l
              fi
              rmdir "$mntdir" 2>/dev/null
          done

          # handle cd to last directory
          if [[ -s $LF_CD_FILE ]]; then
              cd "$(< "$LF_CD_FILE")"
              \rm "$LF_CD_FILE"
          fi
          unset LF_CD_FILE
      }
      # don't use a widget because of https://github.com/gokcehan/lf/issues/585

      autoload -U edit-command-line
      zle -N edit-command-line

      fzf-history-widget() {
        local -r selected=$(fc -rl 1 | ${lib.getExe pkgs.fzf} --height 40% --reverse --padding=1 --query="$LBUFFER")
        
        if [[ -n $selected ]]; then
          local num=$(echo "$selected" | awk '{print $1}')
          zle vi-fetch-history -n $num
        fi
        zle reset-prompt
      }
      zle -N fzf-history-widget

      ks() {
        if ! command -v kdeconnect-cli &> /dev/null; then
          echo "kdeconnect is not installed."
          return 1
        fi

        kdeconnect-cli --refresh
        local device=$(kdeconnect-cli --list-devices --name-only | ${lib.getExe pkgs.fzf} --height 40% --reverse)

        if [ -z "$device" ]; then
          return 1
        fi
        
        echo "Sharing with $device"
        if [[ -z $1 ]]; then
          kdeconnect-cli --send-clipboard -n "$device"
        elif [[ -f $1 || "$1" =~ ^https?:// ]]; then
          kdeconnect-cli --share "$@" -n "$device"
        else
          kdeconnect-cli --share-text "$1" -n "$device"
        fi
      }
    '';
}
