{
  hj.xdg.config.files."zsh/bindings.zsh".text = # bash
    ''
      bindkey -e

      bindkey '\ev' edit-command-line

      bindkey '^T' fzf-history-widget

      bindkey -s '^O' "lf^M"

      export KEYTIMEOUT=1  

      # shift-tab in completion
      bindkey '^[[Z' reverse-menu-complete

      bindkey -M menuselect '^P' up-line-or-history
      bindkey -M menuselect '^N' down-line-or-history

      bindkey -M menuselect '^[' undo

      bindkey -M menuselect '/' history-incremental-search-forward
    '';
}
