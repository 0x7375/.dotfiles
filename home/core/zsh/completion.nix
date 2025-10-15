{
  xdg.configFile."zsh/completion.zsh".text = # bash
    ''
      mkdir -p $XDG_CACHE_HOME/zsh > /dev/null
      autoload -U compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump

      zmodload zsh/complist

      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:*' use-fzf-default-opts yes

      zstyle ':fzf-tab:*' switch-group 'alt-h' 'alt-l'
      zstyle ':fzf-tab:*' fzf-bindings 'ctrl-l:toggle+down'
      zstyle ':fzf-tab:*' continuous-trigger 'ctrl-i'

      zstyle ':completion:*:descriptions' format '[%d]'

      zstyle ':completion:*' use-ip true

      # zstyle ':completion:*' menu yes select
      # zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

      # zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
      # zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
      # zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
      # zstyle ':completion:*' group-name '''

      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
    '';
}
