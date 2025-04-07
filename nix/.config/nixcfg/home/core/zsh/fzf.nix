{
  home.file.".config/zsh/fzf.zsh" = {
    force = true;
    mutable = true;
    text = # bash
      ''
        [[ -o interactive ]] || return 0

        if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ''${+options} )); then
          __fzf_key_bindings_options="options=(''${(j: :)''${(kv)options[@]}})"
          else () {
            __fzf_key_bindings_options="setopt" 'local' '__fzf_opt'
            for __fzf_opt in "''${(@)''${(@f)$(set -o)}%% *}"; do
              if [[ -o "$__fzf_opt" ]]; then
                __fzf_key_bindings_options+=" -o $__fzf_opt"
              else
                __fzf_key_bindings_options+=" +o $__fzf_opt"
              fi
            done
          }
        fi

        builtin emulate zsh
        builtin setopt no_aliases
        {
          __fzfcmd() {
            [ -n "''${TMUX_PANE-}" ] && { [ "''${FZF_TMUX:-0}" != 0 ] || [ -n "''${FZF_TMUX_OPTS-}" ]; } &&
            echo "fzf-tmux ''${FZF_TMUX_OPTS:--d''${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
          }

          _fzf-cd-widget() {
            setopt localoptions pipefail no_aliases 2> /dev/null
            local cmd="find $1 -maxdepth 1 -type d ! -name '.stfolder' ! -name '.stversions' | sed \"s|^$HOME|~|\" | sed 's|^./||'"
            local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=path --bind=ctrl-z:ignore ''${FZF_DEFAULT_OPTS-} ''${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
            if [[ -z "$dir" ]]; then
              zle redisplay
              return 0
            fi
            zle push-input
            BUFFER=" cd $HOME/$dir; clear"
            zle accept-line
          }

          _fzf-file-widget() {
            setopt localoptions pipefail no_aliases 2> /dev/null
            local cmd="find . -type f | sed 's|^./||'"
            local file="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=path --bind=ctrl-z:ignore ''${FZF_DEFAULT_OPTS-} ''${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
            if [[ -z "$file" ]]; then
              zle redisplay
              return 0
            fi
            $EDITOR "$file"
            zle reset-prompt
          }
          zle -N _fzf-file-widget

          function _fzf-cd-current() {
            setopt localoptions pipefail no_aliases 2> /dev/null
            local cmd="find . -type d ! -name '.git' | sed 's|^./||'"
            local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=path --bind=ctrl-z:ignore ''${FZF_DEFAULT_OPTS-} ''${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
            if [[ -z "$dir" ]]; then
              zle redisplay
              return 0
            fi
            zle push-input
            BUFFER=" cd $dir; clear"
            zle accept-line
          }
          zle -N _fzf-cd-current

          function _fzf-cd-projects() {
            _fzf-cd-widget "$HOME/perso $HOME/uni"
          }
          zle -N _fzf-cd-projects

          function _fzf-cd-config() {
            _fzf-cd-widget "$HOME/.config"
          }
          zle -N _fzf-cd-config

          # CTRL-R - Paste the selected command from history into the command line
          _fzf-history-widget() {
            local selected num
            setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
            selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
            FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} ''${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ''${FZF_CTRL_R_OPTS-} --query=''${(qqq)LBUFFER} +m" $(__fzfcmd)) )
            local ret=$?
            if [ -n "$selected" ]; then
              num=$selected[1]
              if [ -n "$num" ]; then
                zle vi-fetch-history -n $num
                fi
            fi
            zle reset-prompt
            return $ret
          }
          zle -N _fzf-history-widget
        } always {
          eval $__fzf_key_bindings_options
          'unset' '__fzf_key_bindings_options'
        }
      '';
  };
}
