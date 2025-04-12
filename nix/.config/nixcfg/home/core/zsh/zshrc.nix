{ pkgs, ... }:

{
  home.file.".config/zsh/.zshrc" = {
    force = true;
    mutable = true;
    text = # bash
      ''
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh
        source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

        source ~/.profile

        source $ZDOTDIR/completion.zsh
        source $ZDOTDIR/opts.zsh
        source $ZDOTDIR/widgets.zsh
        source $ZDOTDIR/bindings.zsh
        source $ZDOTDIR/set-prompt.sh
        source $ZDOTDIR/longcmd-notify.zsh

        mkdir -p "$XDG_STATE_HOME"/zsh > /dev/null
        export HISTFILE="$XDG_STATE_HOME"/zsh/history 
        HISTSIZE=50000
        SAVEHIST=50000

        # only add command that did not fail
        zshaddhistory() { whence ''${''${(z)1}[1]} >| /dev/null || return 1 }

        zle_highlight=('paste:none')

        # allow any character resume terminal after ctrl+s
        stty ixany

        set_prompt
      '';
  };
}
