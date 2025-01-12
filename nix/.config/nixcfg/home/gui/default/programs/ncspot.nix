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
  programs.ncspot = {
    enable = true;
    settings = {
      shuffle = true;
      notify = true;
      repeat = "playlist";
      volnorm = true;
      keybindings = {
        playpause = "XF86AudioPlay";
        previous = "XF86AudioPrev";
        next = "XF86AudioNext";
      };
      theme = {
        background = palette.bg0;
        primary = palette.fg0;
        secondary = palette.bg2;
        title = palette.green;

        playing = palette.green;
        playing_bg = palette.bg0;
        playing_selected = palette.bg2;

        highlight = palette.fg0;
        highlight_bg = palette.bg2;

        error = palette.bg0;
        error_bg = palette.red;

        statusbar = palette.bg0;
        statusbar_progress = palette.green;
        statusbar_bg = palette.green;

        cmdline = palette.fg0;
        cmdline_bg = palette.bg0;

        search_match = palette.orange;
      };
    };
  };
}
