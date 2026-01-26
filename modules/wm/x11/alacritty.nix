{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
in
lib.mkIf (config.me.wm.terminal == "alacritty") {
  packages = [ pkgs.alacritty ];

  tinted.files.".config/alacritty/alacritty.toml" = {
    prefix = false;
    source =
      palette:
      let
        nocolor = "00ff00";
      in
      (pkgs.formats.toml { }).generate "alacritty.toml" {
        colors = {
          primary = {
            background = "0x${palette.bg0}";
            foreground = "0x${palette.fg0}";
          };
          normal = {
            black = "0x${palette.bg1}";
            red = "0x${palette.red}";
            green = "0x${palette.green}";
            yellow = "0x${palette.yellow}";
            blue = "0x${palette.blue}";
            magenta = "0x${palette.magenta}";
            cyan = "0x${palette.cyan}";
            white = "0x${palette.fg3}";
          };
          bright = {
            black = "0x${palette.bg3}";
            red = "0x${nocolor}";
            green = "0x${nocolor}";
            yellow = "0x${nocolor}";
            blue = "0x${palette.fg0}";
            magenta = "0x${palette.bg3}";
            cyan = "0x${palette.bg2}";
            white = "0x${palette.bg0}";
          };
        };
        cursor.style.blinking = "Never";
        mouse.bindings = [
          {
            mouse = "Middle";
            action = "None";
          }
        ];
        keyboard.bindings = [
          {
            key = "u";
            mods = "Alt|Shift";
            action = "IncreaseFontSize";
          }
          {
            key = "d";
            mods = "Alt|Shift";
            action = "DecreaseFontSize";
          }
          {
            key = "r";
            mods = "Alt|Shift";
            action = "ResetFontSize";
          }
          {
            key = "-";
            mods = "Control";
            action = "ReceiveChar";
          }
          {
            key = "+";
            mods = "Control";
            action = "ReceiveChar";
          }
        ]
        ++ (lib.optionals (!isDarwin) [
          {
            key = "v";
            mods = "Alt";
            action = "Paste";
          }
          {
            key = "c";
            mods = "Alt";
            action = "Copy";
          }
        ]);
        window = {
          option_as_alt = "Both";
          decorations = if isDarwin then "None" else "Full";
          dynamic_padding = true;
          padding = rec {
            x = 20;
            y = x;
          };
        };
        font = {
          builtin_box_drawing = true;
          normal = {
            family = "${config.me.wm.font} Nerd Font";
          };
          size = config.me.wm.fontSize;
          offset.y = 0;
        };
      };
  };
}
