{
  xdg.configFile."zsh/completion.zsh".text = # bash
    ''
      mkdir -p $XDG_CACHE_HOME/zsh > /dev/null
      autoload -U compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump

      zmodload zsh/complist

      zstyle ':completion:*' menu yes select
      zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

      zstyle ':completion:*' use-ip true

      zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
      zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
      zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
      zstyle ':completion:*' group-name '''

      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
    '';
}
