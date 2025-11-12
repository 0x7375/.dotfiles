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

      bindkey '^P' history-substring-search-up
      bindkey '^N' history-substring-search-down

      HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=
    '';
}
