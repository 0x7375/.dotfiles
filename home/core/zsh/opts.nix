{
  xdg.configFile."zsh/opts.zsh".text = # bash
    ''
      setopt autocd
      setopt globdots
      setopt nobeep
      setopt nomatch
      setopt menucomplete
      setopt extendedglob
      setopt interactivecomments
      setopt appendhistory
      setopt histignorespace
      setopt histignoredups
      setopt banghist
      setopt extendedhistory
      setopt histexpiredupsfirst
      setopt histignoredups
      setopt histignorealldups
      setopt histfindnodups
      setopt histignorespace
      setopt histsavenodups
      setopt histreduceblanks
      setopt prompt_subst
      setopt inc_append_history_time
      setopt no_nomatch
      unsetopt share_history
    '';
}
