{
  myLib,
  lib,
  config,
  ...
}:

let
  nocolor = "00ff00";
  colors = hex: ''
    [colors.primary]
    background = "0x${hex.bg0}"
    foreground = "0x${hex.fg0}"

    [colors.normal]
    black = "0x${hex.bg1}"
    red = "0x${hex.red}"
    green = "0x${hex.green}"
    yellow = "0x${hex.yellow}"
    blue = "0x${hex.blue}"
    magenta = "0x${hex.magenta}"
    cyan = "0x${hex.cyan}"
    white = "0x${hex.fg3}"

    [colors.bright]
    black = "0x${hex.bg3}" # inline zsh completion and *.old files in lf
    red = "0x${nocolor}"
    green = "0x${nocolor}"
    yellow = "0x${nocolor}"
    blue = "0x${hex.fg0}"
    magenta = "0x${hex.bg3}"
    cyan = "0x${hex.bg2}"
    white = "0x${hex.bg0}"
  '';
in
lib.mkIf (config.me.gui.displayServer == "xorg") {
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [ "theme.toml" ];
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
        dynamic_padding = true;
        padding = rec {
          x = 20;
          y = x;
        };
      };
      font = {
        builtin_box_drawing = true;
        normal = {
          family = "${config.me.gui.font} Nerd Font";
          # style = "Bold";
        };
        size = 18;
        # size = 19;
        offset.y = 0;
      };
    };
  };

  xdg.configFile."alacritty/dark.toml".text = colors myLib.hex;
  xdg.configFile."alacritty/light.toml".text = colors myLib.light_hex;

  systemd.user.tmpfiles.rules =
    let
      alacritty = "/home/${config.me.user}/.config/alacritty";
    in
    [
      "L ${alacritty}/theme.toml - - - - ${alacritty}/dark.toml"
    ];
}
