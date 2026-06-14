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
      }

      [lockscreen_widgets]
      enabled = true
      schema_version = 2
      widget_order = [  "lockscreen-login-box@${main}", "lockscreen-widget-label" ]

          [lockscreen_widgets.grid]
          cell_size = 16
          major_interval = 4
          visible = true

          [lockscreen_widgets.widget."lockscreen-login-box@${main}"]
          box_height = 0.0
          box_width = 0.0
          cx = 711.0
          cy = 765.0
          output = "${main}"
          rotation = 0.0
          type = "login_box"

            [lockscreen_widgets.widget."lockscreen-login-box@${main}".settings]
            show_login_button = false

          [lockscreen_widgets.widget.lockscreen-widget-label]
          box_height = 149.14453125
          box_width = 312.4609375
          cx = 711.0
          cy = 217.005859375
          output = "${main}"
          rotation = 0.0
          type = "label"

              [lockscreen_widgets.widget.lockscreen-widget-label.settings]
              background = false
              background_opacity = 1.0
              background_radius = 10.0
              shadow = false
              title = "~Locked~"
    '';

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
      persistUser = {
        directories = [
          ".cache/noctalia"
          ".config/noctalia"
          {
            directory = ".local/state/noctalia";
            how = "_intermediate";
          }
          ".local/state/noctalia/clipboard"
        ];
        files = [
          {
            file = ".local/state/noctalia/screen_time.json";
            how = "symlink";
          }
        ];
      };

      nixpkgs.overlays = [
        (final: prev: {
          my = (prev.my or { }) // {
            noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                ./truncate_ssid.patch
              ];
            });
            lock = import ./_lock.nix final;
          };
        })
      ];

      packages = with pkgs; [
        my.noctalia
        udisks
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
                  "mango-layout"
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
              session_locked = "systemctl stop --user yubikey-touch-detector";
              session_unlocked = "systemctl start --user yubikey-touch-detector";
              theme_mode_changed = "swap-theme sync";
              started = "swap-theme sync";
            };

            keybinds = {
              down = [ "Ctrl+n" ];
              up = [ "Ctrl+p" ];
            };

            location.auto_locate = true;

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
              setup_wizard_enabled = false;

              session.actions = [
                {
                  action = "lock";
                  enabled = true;
                  variant = "default";
                }
                {
                  action = "suspend";
                  enabled = true;
                  variant = "default";
                }
                {
                  action = "command";
                  command = "loginctl terminate-user ${config.me.user}";
                  enabled = true;
                  glyph = "logout";
                  label = "Log out";
                  variant = "default";
                }
                {
                  action = "shutdown";
                  enabled = true;
                  variant = "destructive";
                }
                {
                  action = "reboot";
                  enabled = true;
                  variant = "default";
                }
                (
                  let
                    switch-to-windows = pkgs.writeShellApplication {
                      name = "switch-to-windows";
                      text = ''
                        ENTRY=$(${lib.getExe pkgs.efibootmgr} | grep -i windows | grep -oP 'Boot\K[0-9A-F]+' | head -1)
                        if [ -n "$ENTRY" ]; then
                          sudo efibootmgr --bootnext "$ENTRY" && systemctl --no-wall reboot
                        fi
                      '';
                    };
                  in
                  {
                    action = "command";
                    command = lib.getExe switch-to-windows;
                    enabled = true;
                    glyph = "brand-windows-filled";
                    label = "Reboot to Windows";
                    variant = "default";
                  }
                )
                {
                  action = "command";
                  command = "systemctl --no-wall reboot --firmware-setup";
                  enabled = true;
                  glyph = "settings";
                  label = "Reboot to UEFI";
                  variant = "default";
                }
              ];
              animation = {
                enabled = true;
                speed = 2.0;
              };
              panel = {
                launcher_categories = false;
                open_near_click_control_center = true;
                session_placement = "floating";
              };
              shadow.alpha = 0.20999999344348907;
            };

            templates = { };

            nightlight.enabled = false;

            theme = {
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
              mango-layout.type = "me/mango-layout:mango-layout";
            };

            plugins.enabled = [ "me/mango-layout" ];
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

      hj.xdg.data.files."noctalia/plugins/mango-layout".source = ./mango_layout;

      systemd.user.services.noctalia = {
        wantedBy = [ "mango-session.target" ];
        partOf = [ "mango-session.target" ];
        after = [ "kanshi.service" ];
        requires = [ "kanshi.service" ];

        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.my.noctalia}";
          Restart = "always";
          RestartSec = 3;
        };
      };

      me.desktop = {
        bindings = {
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
          "Mod+Shift+p" = "noctalia msg panel-open launcher \"/session \"";
        };
      };
    };
}
