{
  lib,
  config,
  mkNixos,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "wayland") (mkNixos {
  programs.foot = {
    enable = true;
    settings = {
      main =
        let
          inherit (config.me.wm.terminalFont) family size;
        in
        {
          font = "${family}:size=${size}";
          horizontal-letter-offset = 0;
          vertical-letter-offset = 0;
          pad = "20x20 center";
          selection-target = "clipboard";
          dpi-aware = "no";
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
      #   regular0 = hex.bg1;
      #   regular1 = hex.red;
      #   regular2 = hex.green;
      #   regular3 = hex.yellow;
      #   regular4 = hex.blue;
      #   regular5 = hex.magenta;
      #   regular6 = hex.cyan;
      #   regular7 = hex.fg3;
      #
      #   bright0 = hex.bg3; # inline zsh completion and *.old files in lf
      #   bright1 = nocolor;
      #   bright2 = nocolor;
      #   bright3 = nocolor;
      #   bright4 = hex.fg0;
      #   bright5 = hex.bg3;
      #   bright6 = hex.bg2;
      #   bright7 = hex.bg0;
      # };
      #
      # colors2 = {
      #   foreground = light_hex.fg0;
      #   background = light_hex.bg0;
      #
      #   regular0 = light_hex.bg1;
      #   regular1 = light_hex.red;
      #   regular2 = light_hex.green;
      #   regular3 = light_hex.yellow;
      #   regular4 = light_hex.blue;
      #   regular5 = light_hex.magenta;
      #   regular6 = light_hex.cyan;
      #   regular7 = light_hex.fg3;
      #
      #   bright0 = light_hex.bg3;
      #   bright1 = nocolor;
      #   bright2 = nocolor;
      #   bright3 = nocolor;
      #   bright4 = nocolor;
      #   bright5 = nocolor;
      #   bright6 = nocolor;
      #   bright7 = nocolor;
      # };
    };
  };
})
