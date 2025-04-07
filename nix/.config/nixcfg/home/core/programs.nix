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
        bg = palette.bg0;
        "bg+" = palette.bg1;
        fg = palette.fg1;
        "fg+" = palette.fg0;
        hl = palette.blue;
        "hl+" = palette.blue;
        border = palette.bg0;
        header = palette.blue;
        info = palette.yellow;
        prompt = palette.yellow;
        pointer = palette.cyan;
        marker = palette.cyan;
        spinner = palette.cyan;
        gutter = palette.bg0;
        scrollbar = palette.bg0;
      };
    };

    bash = {
      enable = true;
      bashrcExtra = # bash
        ''
          # If not running interactively, don't do anything
          [[ $- != *i* ]] && return

          source $ZDOTDIR/set-prompt.sh

          shopt -s autocd
          shopt -s dotglob
          shopt -s failglob
          shopt -s extglob
          shopt -s interactive_comments
          shopt -s histappend
          shopt -s histverify

          bind 'TAB:menu-complete'
          bind 'set completion-ignore-case on'

          HISTCONTROL=ignorespace
          HISTCONTROL=ignoredups
          HISTCONTROL=erasedups
        '';
    };
  };
}
