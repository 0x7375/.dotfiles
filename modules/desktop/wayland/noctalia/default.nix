{ inputs, ... }:
{
  flake.lib.mkNoctaliaLayout =
    {
      main,
      secondary ? null,
    }:
    # toml
    ''
      [notification]
      monitors = [ "${main}" ]
      ${
        if secondary != null then
          # toml
          ''
            [bar.default.monitor.${secondary}]
            auto_hide = true
          ''
        else
          ""
      }'';

  flake.modules.nixos.wayland =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      mkTerminal = p: {
        normal = {
          black = p.bg1;
          inherit (p)
            red
            green
            yellow
            blue
            magenta
            cyan
            ;
          white = p.fg3;
        };
        bright = {
          inherit (p) red green yellow;
          black = p.bg3;
          blue = p.fg0;
          magenta = p.bg3;
          cyan = p.bg2;
          white = p.bg0;
        };
        foreground = p.fg0;
        background = p.bg0;
        selectionFg = p.fg1;
        selectionBg = p.bg3;
        cursorText = p.bg0;
        cursor = p.fg1;
      };

      mkScheme = p: {
        mPrimary = p.green;
        mOnPrimary = p.bg0;
        mSecondary = p.yellow;
        mOnSecondary = p.bg0;
        mTertiary = p.blue;
        mOnTertiary = p.bg0;
        mError = p.red;
        mOnError = p.bg0;
        mSurface = p.bg0_dark;
        mOnSurface = p.fg0;
        mSurfaceVariant = p.bg1;
        mOnSurfaceVariant = p.fg1;
        mOutline = p.bg2;
        mShadow = p.bg0;
        mHover = p.blue;
        mOnHover = p.bg0;
        terminal = mkTerminal p;
      };

      inherit (config.tinted.colors) dark light;
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          my = (prev.my or { }) // {
            # dmenu = pkgs.writeShellScriptBin "dmenu" (builtins.readFile ./_noctalia-dmenu.sh);
            noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
          };
        })
      ];

      packages = with pkgs; [
        my.noctalia
        udisks
        # my.dmenu
        ddcutil
      ];

      hj.xdg.config.files = {
        "noctalia/settings.toml" = {
          generator = (pkgs.formats.toml { }).generate "noctalia-settings";
          value = {
            bar = {
              default = {
                capsule = false;
                center = [ "workspaces" ];
                end = [
                  "tray"
                  "notifications"
                  "clipboard"
                  "brightness"
                  "volume"
                  "battery"
                  "sysmon"
                  "ram"
                  "bluetooth"
                  "network"
                  "clock"
                ];
                margin_edge = 0;
                margin_ends = 0;
                margin_h = 0;
                margin_v = 0;
                radius = 0;
                reserve_space = true;
                shadow = true;
                start = [
                  "Mango"
                  "active_window"
                  "media"
                ];
                widget_spacing = 10;
              };
            };

            brightness = {
              enable_ddcutil = true;
            };

            config = { };

            control_center = {
              sidebar_section = "none";
              shortcuts = [
                { type = "wifi"; }
                { type = "bluetooth"; }
                { type = "caffeine"; }
                { type = "notification"; }
                { type = "screen_recorder"; }
                { type = "dark_mode"; }
              ];
            };

            desktop_widgets.enabled = false;
            dock.enabled = false;
            hooks = {
              theme_mode_changed = "swap-theme sync";
              started = "swap-theme sync";
            };

            keybinds = {
              down = [ "Ctrl+n" ];
              up = [ "Ctrl+p" ];
            };

            location.auto_locate = true;

            noctalia_state.setup_wizard_completed = true;

            notification = {
              background_opacity = 1.0;
              position = "top_center";
              show_app_name = false;
            };

            osd.position = "top_center";

            shell = {
              avatar_path = "${config.me.home}/pictures/ghibli/kiki.jpg";
              clipboard_auto_paste = "off";
              clipboard_confirm_clear_history = false;
              polkit_agent = true;
              screen_time_enabled = true;
              settings_show_advanced = true;
              telemetry_enabled = true;
              animation.enabled = true;
              panel = {
                launcher_categories = false;
                open_near_click_control_center = true;
                session_placement = "floating";
              };
              shadow.alpha = 0.20999999344348907;
            };

            templates = { };

            theme = {
              builtin = "Catppuccin";
              custom_palette = "nix";
              source = "custom";
              templates = {
                enable_builtin_templates = false;
                enable_community_templates = false;
              };
            };

            widget = {
              bluetooth.show_label = true;
              sysmon.show_label = false;
              brightness.show_label = false;
              media.hide_when_no_media = true;
              Mango = {
                hot_reload = true;
                script = "${./mango.lua}";
                type = "scripted";
              };
              ram = {
                show_label = false;
                stat = "ram_pct";
              };
              tray = {
                anchor = false;
                capsule = false;
                drawer = true;
              };
              volume.show_label = false;
              workspaces = {
                capsule = false;
                display = "none";
                hide_when_empty = false;
              };
            };
          };
        };
        "noctalia/palettes/nix.json" = {
          generator = lib.strings.toJSON;
          value = {
            dark = mkScheme dark;
            light = mkScheme light;
          };
        };
        "noctalia/notification-rules.json" = {
          generator = lib.strings.toJSON;
          value.rules = [
            {
              action = "block";
              pattern = "Youtube_Music";
            }
            # {
            #   action = "hide";
            #   pattern = "vesktop";
            # }
          ];
        };
      };

      me.desktop = {
        startup.noctalia = lib.getExe pkgs.my.noctalia;
        bindings =
          let
            # inherit (pkgs.my) dmenu;
            powermenu = pkgs.writeShellApplication {
              name = "custom-session-menu";
              runtimeInputs = with pkgs; [
                efibootmgr
                systemd
                # dmenu
                bemenu
              ];
              text = ''
                # MENU_FILE=$(mktemp /tmp/powermenu.XXXXXX.json)
                # trap 'rm -f "$MENU_FILE"' EXIT
                #
                # cat << 'EOF' > "$MENU_FILE"
                # {
                #   "items": [
                #     {"name": "Lock", "value": "lock", "icon": "lock"},
                #     {"name": "Suspend", "value": "suspend", "icon": "player-pause"},
                #     {"name": "Hibernate", "value": "hibernate", "icon": "zzz"},
                #     {"name": "Reboot", "value": "reboot", "icon": "refresh"},
                #     {"name": "Reboot to UEFI", "value": "rebootToUefi", "icon": "settings"},
                #     {"name": "Reboot to Windows", "value": "windows", "icon": "brand-windows"},
                #     {"name": "Logout", "value": "logout", "icon": "logout"},
                #     {"name": "Shutdown", "value": "poweroff", "icon": "power"}
                #   ]
                # }
                # EOF

                # ACTION=$(dmenu -p "POWER" -f "$MENU_FILE")

                ACTION=$(printf "Lock\nSuspend\nHibernate\nReboot\nReboot to UEFI\nReboot to Windows\nLogout\nShutdown" | bemenu -p "POWER")

                case "$ACTION" in
                  "Lock")         noctalia msg session lock ;;
                  "Suspend")      systemctl suspend ;;
                  "Hibernate")    systemctl hibernate ;;
                  "Reboot")       systemctl --no-wall reboot ;;
                  "Reboot to UEFI") systemctl --no-wall reboot --firmware-setup ;;
                  "Logout")       loginctl terminate-user "$USER" ;;
                  "Shutdown")     systemctl poweroff ;;
                  "Reboot to Windows")
                    ENTRY=$(efibootmgr | grep -i windows | grep -oP 'Boot\K[0-9A-F]+' | head -1)
                    if [ -n "$ENTRY" ]; then
                      sudo efibootmgr --bootnext "$ENTRY" && systemctl --no-wall reboot
                    fi
                    ;;
                  *) exit 0 ;;
                esac
              '';
            };
          in
          {
            "Mod+x" = "noctalia msg notification-clear-active";
            "Mod+i" = "noctalia msg bar-hide";
            "Mod+d" = "noctalia msg panel-open launcher";
            "Mod+c" = "noctalia msg panel-open clipboard";
            # "Mod+r" = "notifications toggleHistory"; # v4
            "Mod+m" =
              let
                dir = "$HOME/notes";
              in
              pkgs.writeShellScript "open-note" ''
                note=$(ls ${dir} | sed 's/\.md$//' | ${lib.getExe pkgs.bemenu} -p "NOTE")
                [ -n "$note" ] && $TERMINAL $EDITOR "${dir}/$note.md"
              '';
            "Mod+Shift+b" = pkgs.writeShellScript "open-bookmark" ''
              file="$HOME/notes/Bookmarks.md"
              [[ ! -f $file ]] && exit
              selection=$(awk -F': ' '{print $1}' "$file" | ${lib.getExe pkgs.bemenu} -p "BOOKMARK")
              [[ -z "$selection" ]] && exit
              url=$(awk -F': ' -v sel="$selection" '$1 == sel {print $2}' "$file")
              [[ -n "$url" ]] && ${config.me.desktop.open} "$url"
            '';
            "Mod+Shift+p" = lib.getExe powermenu;
          };
      };
    };
}
