{
  hj.xdg.config.files."zsh/history.zsh".text = # bash
    ''
      hist_dir="$XDG_STATE_HOME"/zsh
      mkdir -p "$hist_dir" > /dev/null

      export HISTFILE="$hist_dir"/history 
      HOSTFILE="$hist_dir/$(hostname)_history"
      touch "$HISTFILE" "$HOSTFILE"

      HISTSIZE=5000000
      SAVEHIST=5000000

      merge_histories() {
        awk '{lines[NR]=$0; seen[$0]=NR} END{for(i=1;i<=NR;i++) if(seen[lines[i]]==i) print lines[i]}' "$hist_dir"/*_history 2>/dev/null > "$HISTFILE"
      }

      # do not add failed commands to history
      zshaddhistory() {
        emulate -L zsh
        _HISTLINE=''${1%%$'\n'}
        return 1
      }

      precmd() {
        local -i rc=$?
        emulate -L zsh

        # command did not fail, is not empty, does not start with space, is not a single word
        if (( (rc == 0 || rc == 130 || rc == 3 || rc == 4 || rc == 139) && ''${+_HISTLINE} && $#_HISTLINE )) \
          && [[ ! $_HISTLINE =~ '^ ' ]] \
          && [[ ! $_HISTLINE =~ '^[a-zA-Z0-9_-]+$' ]]; then
            builtin print -rs -- "''${(z)_HISTLINE}"
            builtin print -r -- "''${(z)_HISTLINE}" >> "$HOSTFILE"
        fi
        
        merge_histories

        unset _HISTLINE
      }
    '';
}
