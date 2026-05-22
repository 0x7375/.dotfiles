{ inputs, self, ... }:
{
  flake.lib.noctalia = {
    mkToast =
      { pkgs, lib }:
      args:
      let
        json = builtins.toJSON args;
        escaped = lib.escape [ "\\" "\"" ] json;
      in
      "${lib.getExe pkgs.my.noctalia} ipc call toast send \"${escaped}\"";
    call = { pkgs, lib }: args: "${lib.getExe pkgs.my.noctalia} ipc call ${args}";
    infinite = 100000000000;
  };

  flake.modules.nixos.desktop =
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
        mSurface = p.bg0;
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

      plugins = pkgs.applyPatches {
        name = "noctalia-plugins-patched";
        src = inputs.noctalia-plugins;
        patches = [ ./extend_layout_label.patch ];
      };
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          my = (prev.my or { }) // {
            dmenu = pkgs.writeShellScriptBin "dmenu" (builtins.readFile ./_noctalia-dmenu.sh);
            noctalia = inputs.wrappers.wrappers.noctalia-shell.wrap {
              inherit pkgs;
              package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
              inherit (builtins.fromJSON (builtins.readFile ./settings.json)) settings;
              outOfStoreConfig = "${config.me.home}/.config/noctalia";

              preInstalledPlugins =
                lib.genAttrs
                  [
                    "mangowc-layout-switcher"
                    "network-manager-vpn"
                    "dmenu"
                    "kde-connect"
                    "polkit-agent"
                    "usb-drive-manager"
                  ]
                  (name: {
                    sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
                    src = "${plugins.outPath}/${name}";
                  });

              pluginSettings = {
                kde-connect.hideIfNoDeviceConnected = true;
                usb-drive-manager = {
                  autoMount = false;
                  fileBrowser = "xdg-open";
                  terminalCommand = "footclient";
                  showNotifications = true;
                  hideWhenEmpty = true;
                  showBadge = true;
                };
                dmenu = {
                  showToastOnSelect = false;
                  panelPosition = "follow_launcher";
                  showMatchCount = false;
                  showFooter = false;
                };
              };
            };
          };
        })
      ];

      packages = with pkgs; [
        my.noctalia
        udisks
        my.dmenu
        ddcutil
      ];

      hj.xdg.config.files = {
        "noctalia/colorschemes/nix/nix.json" = {
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
            inherit (pkgs.my) dmenu;
            call = self.lib.noctalia.call { inherit pkgs lib; };
            powermenu = pkgs.writeShellApplication {
              name = "custom-session-menu";
              runtimeInputs = with pkgs; [
                efibootmgr
                systemd
                dmenu
              ];
              text = ''
                MENU_FILE=$(mktemp /tmp/powermenu.XXXXXX.json)
                trap 'rm -f "$MENU_FILE"' EXIT

                cat << 'EOF' > "$MENU_FILE"
                {
                  "items": [
                    {"name": "Lock", "value": "lock", "icon": "lock"},
                    {"name": "Suspend", "value": "suspend", "icon": "player-pause"},
                    {"name": "Hibernate", "value": "hibernate", "icon": "zzz"},
                    {"name": "Reboot", "value": "reboot", "icon": "refresh"},
                    {"name": "Reboot to UEFI", "value": "rebootToUefi", "icon": "settings"},
                    {"name": "Reboot to Windows", "value": "windows", "icon": "brand-windows"},
                    {"name": "Logout", "value": "logout", "icon": "logout"},
                    {"name": "Shutdown", "value": "poweroff", "icon": "power"}
                  ]
                }
                EOF

                ACTION=$(dmenu -p "POWER" -f "$MENU_FILE")

                case "$ACTION" in
                  "lock")         ${call "lockScreen lock"} ;;
                  "suspend")      systemctl suspend ;;
                  "hibernate")    systemctl hibernate ;;
                  "reboot")       systemctl --no-wall reboot ;;
                  "rebootToUefi") systemctl --no-wall reboot --firmware-setup ;;
                  "logout")       loginctl terminate-user "$USER" ;;
                  "poweroff")     systemctl poweroff ;;
                  "windows")
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
            "Mod+x" = call "toast dismiss";
            "Mod+i" = call "bar toggle";
            "Mod+d" = call "launcher toggle";
            "Mod+c" = call "launcher clipboard";
            "Mod+r" = call "notifications toggleHistory";
            "Mod+m" =
              let
                dir = "$HOME/notes";
              in
              pkgs.writeShellScript "open-note" ''
                note=$(ls ${dir} | sed 's/\.md$//' | ${lib.getExe dmenu} -p "NOTE")
                [ -n "$note" ] && $TERMINAL $EDITOR "${dir}/$note.md"
              '';
            "Mod+Shift+b" = pkgs.writeShellScript "open-bookmark" ''
              file="$HOME/notes/Bookmarks.md"
              [[ ! -f $file ]] && exit
              selection=$(awk -F': ' '{print $1}' "$file" | ${lib.getExe dmenu} -p "BOOKMARK")
              [[ -z "$selection" ]] && exit
              url=$(awk -F': ' -v sel="$selection" '$1 == sel {print $2}' "$file")
              [[ -n "$url" ]] && ${config.me.desktop.open} "$url"
            '';
            "Mod+Shift+p" = lib.getExe powermenu;
          };
      };
    };
}
