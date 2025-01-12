{
  programs.bash = {
    enable = true;
    bashrcExtra = # bash
      ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return

        source $ZDOTDIR/set-prompt.sh

        shopt -s autocd
        shopt -s dotglob
        shopt -s failglob
        shopt -s extglob
        shopt -s interactive_comments
        shopt -s histappend
        shopt -s histverify

        bind 'TAB:menu-complete'
        bind 'set completion-ignore-case on'

        HISTCONTROL=ignorespace
        HISTCONTROL=ignoredups
        HISTCONTROL=erasedups

        command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
      '';
  };
}
