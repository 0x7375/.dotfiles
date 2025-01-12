{
  myLib,
  config,
  lib,
  ...
}:

let
  palette = myLib.palette;
in
lib.mkIf config.me.gui.enable {
  programs.zathura = {
    enable = true;
    options = {
      statusbar-h-padding = 0;
      statusbar-v-padding = 0;
      selection-clipboard = "clipboard";
      selection-notification = false;
      guioptions = "none";

      scroll-full-overlap = "0.01";
      scroll-step = 100;

      default-bg = palette.bg0;
      default-fg = palette.fg0;
      render-loading = true;
      render-loading-bg = palette.bg0;
      render-loading-fg = palette.fg0;

      recolor-lightcolor = palette.bg0;
      recolor-darkcolor = palette.fg0;
      # recolor = true; # dark mode by default
      # recolor-keephue = true; # keep images/graphes default color

      index-bg = palette.bg2;
      index-fg = palette.fg0;
      index-active-bg = palette.blue;
      index-active-fg = palette.bg2;

      highlight-color = "rgba(250,189,47,0.5)";
      highlight-active-color = "rgba(254,128,25,0.5)";

      statusbar-bg = palette.bg2;
      statusbar-fg = palette.fg0;

      inputbar-bg = palette.bg0;
      inputbar-fg = palette.fg0;

      notification-error-bg = palette.bg0;
      notification-error-fg = palette.red;
      notification-warning-bg = palette.bg0;
      notification-warning-fg = palette.yellow;
      notification-bg = palette.bg0;
      notification-fg = palette.green;

      completion-bg = palette.bg2;
      completion-fg = palette.fg0;
      completion-group-bg = palette.bg1;
      completion-group-fg = palette.fg4;
      completion-highlight-bg = palette.blue;
      completion-highlight-fg = palette.bg2;
    };
    mappings = {
      "<C-j>" = "navigate next";
      "<C-k>" = "navigate previous";
      "<Right>" = "navigate next";
      "<Left>" = "navigate previous";
      f = "navigate next";
      b = "navigate previous";

      u = "scroll half-up";
      d = "scroll half-down";
      D = "toggle_page_mode";
      r = "reload";
      R = "reload";
      K = "zoom in";
      J = "zoom out";
      i = "recolor";

      "<C-p>" = "print";
      "<C-N>" = "exec 'zathura \"$FILE\"'";
      "[index] <C-m>" = "navigate_index select";
    };
  };
}
