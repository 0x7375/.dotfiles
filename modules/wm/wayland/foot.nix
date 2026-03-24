{
  flake.nixos.wayland =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      mkColors = p: {
        foreground = p.fg0;
        background = p.bg0;
        regular0 = p.bg1;
        regular1 = p.red;
        regular2 = p.green;
        regular3 = p.yellow;
        regular4 = p.blue;
        regular5 = p.magenta;
        regular6 = p.cyan;
        regular7 = p.fg3;
        bright0 = p.bg3;
        bright1 = p.red;
        bright2 = p.green;
        bright3 = p.yellow;
        bright4 = p.fg0;
        bright5 = p.bg3;
        bright6 = p.bg2;
        bright7 = p.bg0;
      };
    in
    {
      me.wm.startup.foot = "${lib.getExe pkgs.foot} --server";

      programs.foot = {
        enable = true;
        settings =
          let
            inherit (config.me.hex) dark light;
          in
          {
            main =
              let
                inherit (config.me.wm.terminal.font) family size;
              in
              {
                font = "${family}:size=${toString size}";
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

            colors = mkColors dark;
            colors2 = mkColors light;
          };
      };
    };
}
