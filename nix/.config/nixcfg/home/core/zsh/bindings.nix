{
  home.file.".config/zsh/bindings.zsh" = {
    force = true;
    mutable = true;
    text = # bash
      ''
        bindkey -e

        bindkey '\ev' edit-command-line
        bindkey '\es' prepend-sudo

        bindkey '\ec' _fzf-cd-current
        bindkey '^R' _fzf-history-widget
        bindkey '^T' _fzf-cd-config
        # bindkey '^J' _fzf-cd-projects

        bindkey '^V' _fzf-file-widget

        bindkey -s '^O' "lfcd^M"

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
  };
}
