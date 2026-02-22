{
  pkgs,
  lib,
  config,
  mkBundle,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
in
lib.mkIf (config.me.wm.terminal == "alacritty") (mkBundle {
  nixos.packages = [ pkgs.alacritty ];
  darwin.homebrew.casks = [ "alacritty" ];

  tinted.files.".config/alacritty/alacritty.toml" = {
    prefix = false;
    source =
      p:
      (pkgs.formats.toml { }).generate "alacritty.toml" {
        colors = {
          primary = {
            background = "0x${p.bg0}";
            foreground = "0x${p.fg0}";
          };
          normal = {
            black = "0x${p.bg1}";
            red = "0x${p.red}";
            green = "0x${p.green}";
            yellow = "0x${p.yellow}";
            blue = "0x${p.blue}";
            magenta = "0x${p.magenta}";
            cyan = "0x${p.cyan}";
            white = "0x${p.fg3}";
          };
          bright = {
            black = "0x${p.bg3}";
            red = "0x${p.red}";
            green = "0x${p.green}";
            yellow = "0x${p.yellow}";
            blue = "0x${p.fg0}";
            magenta = "0x${p.bg3}";
            cyan = "0x${p.bg2}";
            white = "0x${p.bg0}";
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
        ];
        window = {
          option_as_alt = "Both";
          decorations = if isDarwin then "None" else "Full";
          dynamic_padding = true;
          padding = rec {
            x = 20;
            y = x;
          };
        };
        font =
          let
            inherit (config.me.wm.terminalFont) family size;
          in
          {
            builtin_box_drawing = true;
            normal = {
              inherit family;
            };
            inherit size;
            offset.y = 0;
          };
      };
  };
})
