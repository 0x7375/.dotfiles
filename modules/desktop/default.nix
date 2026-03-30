{ self, ... }:

{
  flake.shared.desktop =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.me.desktop;
    in
    {
      options.me.desktop =
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

          scaling = mkOption {
            type = lib.types.float;
            default = 1.0;
            description = "Scaling factor";
          };

          open = mkOption {
            type = lib.types.str;
            default = if pkgs.stdenv.isDarwin then "open" else lib.getExe' pkgs.xdg-utils "xdg-open";
          };

          copy =
            let
              inherit (lib) getExe';
            in
            mkOption {
              type = lib.types.str;
              default = if pkgs.stdenv.isDarwin then "pbcopy" else getExe' pkgs.wl-clipboard "wl-copy";
            };

          terminal = {
            name = mkOption {
              type = types.str;
              description = "Default terminal emulator";
            };
            cmd = mkOption {
              type = types.str;
              description = "Default terminal command";
            };
          };

          barFontSize = mkOption {
            type = types.int;
            default = 13;
            description = "Top bar font size";
            internal = true;
          };
        };

      config.vars.TERMINAL = "${cfg.terminal.cmd} -e";
    };

  flake.darwin.desktop = {
    imports = [ self.shared.desktop ];
  };

  flake.nixos.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) getExe getExe';
      cfg = config.me.desktop;
    in
    {
      imports = [ self.shared.desktop ];

      hardware.i2c.enable = true;

      users.users.${config.me.user}.extraGroups = [
        "i2c"
        "video"
      ];

      zramSwap.memoryPercent = lib.mkForce 100;

      xdg.terminal-exec.enable = true;
      hj.xdg.config.files."xdg-terminals.list".text =
        builtins.head config.xdg.terminal-exec.settings.default;

      me.desktop.bindings =
        let
          change-brightness = getExe (
            pkgs.writeShellApplication {
              name = "change-brightness";
              runtimeInputs = with pkgs; [
                brillo
                ddcutil
              ];
              text = ''
                fade=150000

                get_brightness() {
                  local -r device="dev:$1"
                  ddccontrol -r 0x10 "$device" 2>/dev/null | grep "Control 0x10:" | cut -d'/' -f2
                }

                set_brightness() {
                  local -r device="dev:$1"
                  local -ri value=$2
                  ddccontrol -r 0x10 -w "$value" "$device" &> /dev/null
                }

                case $1 in
                up)
                    brillo -u $fade -q -A 10
                    ;;
                down)
                    brillo -u $fade -q -U 10
                    ;;
                esac

                for device in "/dev/i2c-2" "/dev/i2c-4"; do
                  current=$(get_brightness "$device")
                  case $1 in
                  up)
                      current=$(("$current" + 10))
                      [[ $current -gt 100 ]] && current=100
                      ;;
                  down)
                      current=$(("$current" - 10))
                      [[ $current -lt 0 ]] && current=0
                      ;;
                  esac
                  set_brightness "$device" "$current" &
                done
              '';
            }
          );
          term = pkgs.${cfg.terminal.name} + "/bin/" + cfg.terminal.cmd;

          btToggle =
            let
              inherit (lib) getExe';
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

          screenshot = pkgs.writeShellApplication {
            name = "screenshot";
            runtimeInputs = with pkgs; [
              coreutils
              xdg-user-dirs
              libnotify
              hyprshot
            ];
            text = ''
              time=$(date -u "+%s" | cut -c 7-)
              file="Screenshot-$(date -u +%d-%m-%Y-"$time").png"
              folder="$(xdg-user-dir SCREENSHOTS)/"

              [[ -z $1 ]] && echo "Usage: screenshot {region|window|monitor}" && exit 1

              hyprshot -o "$folder" -f "$file" -m "$1"
            '';
          };
        in
        {
          XF86MonBrightnessUp = "${change-brightness} up";
          XF86MonBrightnessDown = "${change-brightness} down";
          Print = "${getExe screenshot} region";
          "Alt+Sys_Req" = "${getExe screenshot} window";
          "Shift+Print" = "${getExe screenshot} monitor";

          "Mod+t" = "${term} -e ${getExe pkgs.my.tmux-sessionizer} ~/";
          "Mod+Shift+t" = term;

          "Mod+s" = "${term} -e ${getExe pkgs.my.tmux-sshr}";
          "Mod+Shift+s" = getExe pkgs.my.swap-theme;
          "Mod+e" = "${term} -e ${getExe pkgs.lf}";
          "Mod+Shift+e" = "${term} -e sudo ${getExe pkgs.lf}";
          # "Mod+n" =
          #   "${term} -e ${getExe pkgs.zsh} -c '${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${getExe' pkgs.networkmanager "nmtui"}'";
          "Mod+Alt+n" = "${getExe' pkgs.networkmanager "nmcli"} device wifi rescan";
          "Mod+Alt+b" = btToggle;
          "Mod+Shift+i" = getExe wizToggle;

          "Mod+Shift+c" = getExe (
            pkgs.writeShellApplication {
              name = "color-picker";
              runtimeInputs = with pkgs; [
                coreutils-full
                libnotify
                imagemagick
                hyprpicker
              ];
              text = ''
                size="80x80"
                color=$(hyprpicker -ra) && {
                  notify-send --icon "/tmp/color.png" "Copied $color to clipboard"
                  convert -size "$size" xc:"$color" /tmp/color.png
                }
              '';
            }
          );
        };

      services.dbus.enable = true;
    };
}
