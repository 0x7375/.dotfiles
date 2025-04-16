{
  myLib,
  pkgs,
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
    package = pkgs.ncspot.override {
      ueberzug = pkgs.ueberzugpp;
      withCover = true;
    };
    settings = {
      shuffle = true;
      notify = true;
      repeat = "playlist";
      volnorm = true;
      flip_status_indicators = true;
      backend = "pulseaudio";
      keybindings = {
        playpause = "XF86AudioPlay";
        previous = "XF86AudioPrev";
        next = "XF86AudioNext";
        "Ctrl+h" = "back";
        Esc = "back";
        Q = "focus queue";
        L = "focus library";
        S = "focus search";
        C = "focus cover";
        J = "next";
        K = "previous";
        q = "queue; move down 1; queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1;queue; move down 1; queue; move down 1";
      };
      theme = {
        background = palette.bg0;
        primary = palette.fg0;
        secondary = palette.bg2;
        title = palette.green;

        playing = palette.green;
        playing_bg = palette.bg0;
        playing_selected = palette.green;

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
