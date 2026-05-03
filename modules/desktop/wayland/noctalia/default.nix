{ self, ... }:

{
  flake.lib.noctalia = {
    mkToast =
      { pkgs, lib }:
      args:
      let
        json = builtins.toJSON args;
        # allow variables to be used
        escaped = lib.escape [ "\\" "\"" ] json;
      in
      "${lib.getExe pkgs.noctalia} ipc call toast send \"${escaped}\"";
    call = { pkgs, lib }: args: "${lib.getExe pkgs.noctalia} ipc call ${args}";
    infinite = 100000000000;
  };

  flake.nixos.desktop =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          noctalia = final.unstable.noctalia-shell.override { wl-clipboard = final.wl-clipboard-rs; };

          my = (prev.my or { }) // {
            dmenu = pkgs.writeShellScriptBin "dmenu" (builtins.readFile ./_noctalia-dmenu.sh);
          };
        })
      ];

      packages = with pkgs; [
        noctalia
        udisks
        my.dmenu
      ];

      me.desktop = {
        startup.noctalia = lib.getExe pkgs.noctalia;
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
              pkgs.writeShellScript "open-note"
                # bash
                ''
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
