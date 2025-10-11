{ myLib, ... }:

let
  palette = myLib.palette;
in
{
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
        style = "header,grid";
      };
    };

    fzf = {
      enable = true;
      colors = {
        # bg = -1;

        # "bg+" = palette.bg1;
        # fg = palette.fg1;
        # "fg+" = palette.fg0;
        # hl = palette.blue;
        # "hl+" = palette.blue;

        border = "-1";

        # header = palette.blue;
        # info = palette.yellow;
        # prompt = palette.yellow;
        # pointer = palette.cyan;
        # marker = palette.cyan;
        # spinner = palette.cyan;

        gutter = "-1";
        scrollbar = "-1";
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
