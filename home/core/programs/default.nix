{
  programs = {
    fzf = {
      enable = true;
      defaultOptions = [
        "--color=bw"
        "--pointer='>'"
        "--scrollbar=\\ "
        "--separator=\\ "
      ];
      colors = {
        border = "0";
        preview-border = "0";
      };
    };

    bash = {
      enable = true;
      historyControl = [
        "ignorespace"
        "ignoredups"
        "erasedups"
      ];
      historySize = 10000;
      historyFileSize = 10000;
      historyFile = "$XDG_STATE_HOME/bash/history";
      shellOptions = [
        "autocd"
        "dotglob"
        "failglob"
        "interactive_comments"
      ];
      initExtra = # bash
        ''
          source $ZDOTDIR/set-prompt.sh

          bind 'TAB:menu-complete'
          bind 'set completion-ignore-case on'

          set_prompt
        '';
    };
  };
}
