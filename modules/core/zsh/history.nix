{
  hj.xdg.state.files."zsh/.stignore".text = ''
    .hist-sync.lock
    history
  '';

  hj.xdg.config.files."zsh/history.zsh".text = # bash
    ''
      hist_dir="$XDG_STATE_HOME"/zsh
      mkdir -p "$hist_dir" > /dev/null
      export HISTFILE="$hist_dir"/history 
      HISTSIZE=5000000
      SAVEHIST=5000000

      merge_histories() {
        tac "$hist_dir"/*_history @nerr | awk '!seen[$0]++' | tac > "$HISTFILE"
      }

      merge_histories

      ( 
        (
          flock -n 9 || exit 0
          while true; do
            cp "$HISTFILE" "$hist_dir/$(hostname)_history" @null
            sleep 300
            merge_histories
          done
        ) 9>"$hist_dir/.hist-sync.lock" &
      )

      # do not add failed commands to history
      zshaddhistory() {
        emulate -L zsh
        _HISTLINE=''${1%%$'\n'}
        return 1
      }

      precmd() {
        local -i rc=$?
        emulate -L zsh
        if (( $rc == 0 && $+_HISTLINE && $#_HISTLINE )); then
          builtin print -rs -- $_HISTLINE
          unset _HISTLINE
        fi
      }
    '';
}
