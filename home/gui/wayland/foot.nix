{
  myLib,
  lib,
  config,
  ...
}:
let
  hex = myLib.hex;
in
lib.mkIf (config.me.gui.displayServer == "wayland") {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "0xproto Nerd Font:size=${toString config.me.gui.fontSize}:style=Bold";
        horizontal-letter-offset = 0;
        vertical-letter-offset = 0;
        pad = "10x10 center";
        selection-target = "clipboard";
        dpi-aware = "yes";
      };

      bell = {
        urgent = "no";
        notify = "no";
      };

      scrollback = {
        lines = 10000;
        multiplier = 3;
        indicator-position = "relative";
        indicator-format = "line";
      };

      cursor = {
        style = "block";
        blink = "no";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      mouse-bindings = {
        primary-paste = "none";
      };

      key-bindings = {
        clipboard-paste = "Mod1+v";
        clipboard-copy = "Mod1+c";
        font-decrease = "Mod1+Shift+d";
        font-increase = "Mod1+Shift+u";
        font-reset = "Mod1+Shift+r";
      };

      # colors = {
      #   foreground = hex.fg0;
      #   background = hex.bg0;
      #
      #   regular0 = hex.bg3;
      #   regular1 = hex.red;
      #   regular2 = hex.green;
      #   regular3 = hex.yellow;
      #   regular4 = hex.blue;
      #   regular5 = hex.magenta;
      #   regular6 = hex.cyan;
      #   regular7 = hex.fg3;
      #   bright0 = hex.bg3;
      #   bright1 = hex.red;
      #   bright2 = hex.green;
      #   bright3 = hex.yellow;
      #   bright4 = hex.blue;
      #   bright5 = hex.magenta;
      #   bright6 = hex.cyan;
      #   bright7 = hex.fg0;
      # };
    };
  };
}
