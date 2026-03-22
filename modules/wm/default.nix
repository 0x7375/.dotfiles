{
  pkgs,
  config,
  lib,
  mkBundle,
  ...
}:

let
  cfg = config.me.wm;
in
{
  options.me.wm =
    let
      inherit (lib) mkOption types mkEnableOption;

      mkCmdType =
        extraOpts:
        types.attrsOf (
          types.coercedTo (types.either types.str types.package) (cmd: { cmd = "${cmd}"; }) (
            types.submodule {
              options = {
                cmd = mkOption {
                  type = types.coercedTo types.package (p: "${p}") types.str;
                };
              }
              // extraOpts;
            }
          )
        );

      mkRuleType =
        extraOpts:
        types.listOf (
          types.submodule {
            options = {
              type = mkOption {
                type = types.enum [
                  "class"
                  "title"
                  "instance"
                ];
                default = "class";
              };
              name = mkOption { type = types.str; };
            }
            // extraOpts;
          }
        );
    in
    {
      enable = mkEnableOption "Enable graphical config";

      bindings = mkOption {
        type = mkCmdType {
          release = mkEnableOption "create a release binding";
        };
        default = { };
      };

      startup = mkOption {
        type = mkCmdType {
          always = mkEnableOption "run on window-manager restart";
        };
        default = { };
      };

      floating = mkOption {
        type = mkRuleType {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
        };
        default = [ ];
      };

      assign = mkOption {
        type = mkRuleType {
          workspace = mkOption { type = types.str; };
        };
        default = [ ];
      };

      displayServer = mkOption {
        type = types.nullOr (
          types.enum [
            "xorg"
            "wayland"
            "macos"
          ]
        );
        default = if cfg.enable then "xorg" else null;
        description = "Display server to use";
      };

      open = mkOption {
        type = lib.types.str;
        default = if pkgs.stdenv.isDarwin then "open" else lib.getExe' pkgs.xdg-utils "xdg-open";
      };

      copy =
        let
          inherit (lib) getExe' getExe;
        in
        mkOption {
          type = lib.types.str;
          default =
            if pkgs.stdenv.isDarwin then
              "pbcopy"
            else if cfg.displayServer == "wayland" then
              getExe' pkgs.wl-clipboard "wl-copy"
            else
              "${getExe pkgs.xsel} -ib";
        };

      terminal = mkOption {
        type = types.nullOr types.str;
        default =
          if cfg.displayServer == "xorg" then
            "alacritty"
          else if cfg.displayServer == "wayland" then
            "foot"
          else
            "xterm-256color";
        description = "Default terminal emulator";
      };

      barHeight = mkOption {
        type = types.int;
        default = 35;
        description = "Top bar height";
        internal = true;
      };

      barFontSize = mkOption {
        type = types.int;
        default = 13;
        description = "Top bar font size";
        internal = true;
      };
    };

  config =
    let
      inherit (lib) getExe getExe';
    in
    lib.mkIf cfg.enable (mkBundle {
      assertions = [
        {
          assertion = cfg.displayServer == null || config.me.wm.enable;
          message = "Display server '${cfg.displayServer}' requires wm.enable to be true";
        }
      ];

      nixos = {
        zramSwap.memoryPercent = lib.mkForce 100;

        xdg.terminal-exec = {
          enable = true;
          settings.default = [
            "foot.desktop"
            "Alacritty.desktop"
          ];
        };

        me.wm.bindings =
          let
            change-brightness = getExe pkgs.my.change-brightness;
            screenshot = getExe pkgs.my.screenshot;
            term = getExe pkgs.${cfg.terminal};

            openNote =
              let
                dir = "$HOME/notes";
              in
              pkgs.writeShellScript "open-note"
                # bash
                ''
                  note=$(ls ${dir} | sed 's/\.md$//' | ${getExe pkgs.bemenu} -p "NOTE")
                  [ -n "$note" ] && echo $EDITOR "${dir}/$note.md"
                '';

            btToggle =
              let
                airpods = "D4:68:AA:88:8E:32";
              in
              pkgs.writeShellScript "bluetooth-toggle"
                # bash
                ''
                  if ${getExe' pkgs.bluez "bluetoothctl"} info ${airpods} | grep -q "Connected: yes"; then
                    echo -e "disconnect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
                  else
                    echo -e "connect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
                  fi
                '';

            wizToggle =
              pkgs.writers.writePython3Bin "wiz-toggle" { libraries = [ pkgs.python3Packages.pywizlight ]; }
                ''
                  import asyncio
                  from pywizlight import wizlight, PilotBuilder


                  async def main():
                      bulb = wizlight("192.168.1.110")
                      try:
                          state = await bulb.updateState()
                          if state.get_scene_id() == 14:
                              await bulb.turn_on(PilotBuilder(colortemp=3000, brightness=255))
                          else:
                              await bulb.turn_on(PilotBuilder(scene=14))
                      finally:
                          await bulb.async_close()

                  asyncio.run(main())
                '';
          in
          {
            XF86MonBrightnessUp = "${change-brightness} up";
            XF86MonBrightnessDown = "${change-brightness} down";
            Print = "${screenshot} region";
            "Alt+Sys_Req" = "${screenshot} window";
            "Shift+Print" = "${screenshot} monitor";

            "Mod+Shift+n" = "${getExe' pkgs.networkmanager "nmcli"} device wifi rescan";
            "Mod+t" = "${term} -e ${getExe pkgs.my.tmux-sessionizer} ~/";
            "Mod+Shift+t" = term;

            "Mod+s" = "${term} -e ${getExe pkgs.my.tmux-sshr}";
            "Mod+Shift+s" = getExe pkgs.my.swap-theme;
            "Mod+e" = "${term} -e ${getExe pkgs.lf}";
            "Mod+Shift+e" = "${term} -e sudo ${getExe pkgs.lf}";
            "Mod+m" = "${term} -e $(${openNote})";
            "Mod+n" =
              "${term} -e ${getExe pkgs.zsh} -c '${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${getExe' pkgs.networkmanager "nmtui"}'";
            "Mod+Shift+b" = btToggle;
            # "Mod+d" = "${getExe pkgs.j4-dmenu-desktop} --no-generic -d '${getExe pkgs.bemenu} -p \"DESKTOP\"'";
            "Mod+d" = "${lib.getExe pkgs.vicinae} open";
            "Mod+p" = getExe pkgs.my.powermenu;
            "Mod+Shift+i" = getExe wizToggle;

            "Mod+Shift+c" = {
              cmd = getExe pkgs.my.color-picker;
              release = true;
            };
          };

        activation = getExe pkgs.my.generate-icons;
        services.dbus.enable = true;
      };
    });
}
