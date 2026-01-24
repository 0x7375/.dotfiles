{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
  };

  hj.xdg.config.files."zsh/.zshrc".text = 
    # bash
    ''
      source /etc/profile

      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
      export ZSH_AUTOSUGGEST_STRATEGY=(history)
      export ZSH_AUTOSUGGEST_USE_ASYNC=1

      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      source $ZDOTDIR/completion.zsh
      source $ZDOTDIR/opts.zsh
      source $ZDOTDIR/widgets.zsh
      source $ZDOTDIR/bindings.zsh
      source $ZDOTDIR/set-prompt.sh
      source $ZDOTDIR/global-aliases.zsh
      source $ZDOTDIR/longcmd-notify.zsh 2>/dev/null
      source $ZDOTDIR/history.zsh

      zle_highlight=('paste:none')

      # allow any character to resume terminal after ctrl+s
      stty ixany

      set_prompt
    '';
}
