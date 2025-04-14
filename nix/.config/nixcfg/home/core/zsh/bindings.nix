{
  xdg.configFile."zsh/bindings.zsh".text = # bash
    ''
      bindkey -e

      bindkey '\ev' edit-command-line

      # bindkey '^R' fzf-history-widget
      bindkey '^R' fzf-atuin-history-widget

      bindkey -s '^O' "lf^M"

      bindkey '^J' tmux-sessionizer-widget

      bindkey '^P' history-substring-search-up
      bindkey '^N' history-substring-search-down
      HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

      # shift-tab in completion
      bindkey '^[[Z' reverse-menu-complete

      export KEYTIMEOUT=1  

      bindkey -M menuselect '^P' up-line-or-history
      bindkey -M menuselect '^N' down-line-or-history

      bindkey -M menuselect '^[' undo

      bindkey -M menuselect '/' history-incremental-search-forward
    '';
}
