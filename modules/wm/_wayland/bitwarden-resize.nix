{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "wayland") {
  wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.writeShellScript "hyprland-bitwarden-resize" ''
      handle() {
        case $1 in
          windowtitle*)
            window_id=''${1#*>>}
            window_info=$(hyprctl clients -j | ${lib.getExe pkgs.jq} --arg id "0x$window_id" '.[] | select(.address == ($id))')
            window_title=$(echo "$window_info" | ${lib.getExe pkgs.jq} '.title')
            if [[ "$window_title" == *"(Bitwarden Password Manager) - Bitwarden"* ]]; then

              hyprctl --batch "dispatch togglefloating address:0x$window_id ; dispatch resizewindowpixel exact 500 800,address:0x$window_id"
            fi
            ;;
        esac
      }
      ${lib.getExe pkgs.socat} -U - UNIX-CONNECT:/run/user/${toString config.me.uid}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
    ''}"
  ];
}
