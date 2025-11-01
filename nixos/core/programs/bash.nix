{
  hj.files.".bashrc".text = # bash
    ''
      [[ $- == *i* ]] || return

      HISTCONTROL=ignorespace:ignoredups:erasedups
      HISTFILE="$XDG_STATE_HOME/bash/history"
      HISTFILESIZE=10000
      HISTSIZE=10000
      mkdir -p "$(dirname "$HISTFILE")"

      shopt -s autocd
      shopt -s dotglob
      shopt -s failglob
      shopt -s interactive_comments

      source $ZDOTDIR/set-prompt.sh

      bind 'TAB:menu-complete'
      bind 'set completion-ignore-case on'

      set_prompt
    '';
}
