{
  myLib,
  lib,
  config,
  ...
}:

let
  hex = myLib.hex;
in
lib.mkIf (config.me.gui.displayServer == "xorg") {
  programs.alacritty = {
    enable = true;
    settings = {
      cursor.style.blinking = "Never";
      mouse.bindings = [
        {
          mouse = "Middle";
          action = "None";
        }
      ];
      keyboard.bindings = [
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
      ];
      window = {
        padding = rec {
          x = 10;
          y = x;
        };
      };
      font = {
        builtin_box_drawing = true;
        normal = {
          family = "${config.me.gui.font} Nerd Font";
          style = "Bold";
        };
        size = 16;
        # size = 19;
        offset.y = 0;
      };
      colors = {
        primary = {
          background = "0x${hex.bg0}";
          foreground = "0x${hex.fg0}";
        };
        normal = {
          black = "0x${hex.bg3}";
          red = "0x${hex.red}";
          green = "0x${hex.green}";
          yellow = "0x${hex.yellow}";
          blue = "0x${hex.blue}";
          magenta = "0x${hex.magenta}";
          cyan = "0x${hex.cyan}";
          white = "0x${hex.fg3}";
        };
        bright = {
          black = "0x${hex.bg3}";
          red = "0x${hex.red}";
          green = "0x${hex.green}";
          yellow = "0x${hex.yellow}";
          blue = "0x${hex.blue}";
          magenta = "0x${hex.magenta}";
          cyan = "0x${hex.cyan}";
          white = "0x${hex.fg0}";
        };
      };
    };
  };
}
