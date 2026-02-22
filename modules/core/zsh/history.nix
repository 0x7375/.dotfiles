{
  hj.xdg.config.files."zsh/history.zsh".text = # bash
    ''
      hist_dir="$XDG_STATE_HOME"/zsh
      mkdir -p "$hist_dir" > /dev/null

      export HISTFILE="$hist_dir"/history 

      # generate a unique ID once per machine to avoid
      # syncthing conflicts on new install
      id_file="$hist_dir/machine_id"
      [[ ! -f "$id_file" ]] && uuidgen > "$id_file"
      machine_id=$(< "$id_file")

      HOSTFILE="$hist_dir/$(hostname)_''${machine_id}_history"
      touch "$HISTFILE" "$HOSTFILE"

      HISTSIZE=5000000
      SAVEHIST=5000000

      merge_histories() {
        # Keep only the most recent occurrence of each command across all history files, sorted by timestamp
        sort -t':' -k2,2n "$hist_dir"/*_history 2>/dev/null | awk '
          {
            # Extract command content, ignoring timestamp
            if (match($0, /^: [0-9]+:[0-9]+;/)) {
              cmd = substr($0, RLENGTH + 1)
            } else { cmd = $0 }
            
            lines[NR]=$0
            cmds[NR]=cmd
            seen[cmd]=NR 
          } 
          END {
            for(i=1;i<=NR;i++) 
              if(seen[cmds[i]]==i) print lines[i]
          }' > "$HISTFILE"
      }

      zshaddhistory() {
        emulate -L zsh
        _HISTLINE=''${1%%$'\n'}
        return 2
      }

      precmd() {
        local -i rc=$?
        emulate -L zsh

        # command did not fail, is not empty, does not start with space, is not a single word
        if (( (rc == 0 || rc == 130 || rc == 3 || rc == 4 || rc == 139) && ''${+_HISTLINE} && $#_HISTLINE )) \
          && [[ ! $_HISTLINE =~ '^ ' ]] \
          && [[ ! $_HISTLINE =~ '^[a-zA-Z0-9_-]+$' ]]; then

          builtin print -r -- ": $(date +%s):0;''${(z)_HISTLINE}" >> "$HOSTFILE"
        fi
        
        merge_histories

        unset _HISTLINE
      }
    '';
}
