{ self, ... }:

{
  flake.nixos.alacritty =
    { pkgs, ... }:
    {
      imports = [ self.shared.alacritty ];

      xdg.terminal-exec.settings.default = [ "Alacritty.destop" ];

      packages = [ pkgs.alacritty ];
    };

  flake.darwin.alacritty = {
    imports = [ self.shared.alacritty ];

    homebrew.casks = [ "alacritty" ];
  };

  flake.shared.alacritty =
    {
      pkgs,
      config,
      ...
    }:
    {
      me.desktop.terminal = {
        name = "alacritty";
        cmd = "alacritty";
      };

      tinted.files.".config/alacritty/alacritty.toml" = {
        prefix = false;
        generator = (pkgs.formats.toml { }).generate "alacritty.toml";
        value = p: {
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
            decorations = "None";
            dynamic_padding = true;
            padding = rec {
              x = 20;
              y = x;
            };
          };
          font =
            let
              inherit (config.me.desktop.terminal.font) family size;
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
    };
}
