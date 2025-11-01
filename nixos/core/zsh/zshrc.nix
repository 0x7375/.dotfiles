{ pkgs, ... }:

{
  hj.xdg.config.files."zsh/.zshrc".text = # bash
    ''
      source /etc/profile

      source $ZDOTDIR/completion.zsh

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      source $ZDOTDIR/opts.zsh
      source $ZDOTDIR/widgets.zsh
      source $ZDOTDIR/bindings.zsh
      source $ZDOTDIR/set-prompt.sh
      source $ZDOTDIR/global-aliases.zsh
      source $ZDOTDIR/longcmd-notify.zsh 2>/dev/null

      mkdir -p "$XDG_STATE_HOME"/zsh > /dev/null
      export HISTFILE="$XDG_STATE_HOME"/zsh/history 
      HISTSIZE=50000
      SAVEHIST=50000

      # only add valid commands to history
      zshaddhistory() { whence ''${''${(z)1}[1]} >| /dev/null || return 1 }

      zle_highlight=('paste:none')

      # allow any character to resume terminal after ctrl+s
      stty ixany

      set_prompt
    '';
}
