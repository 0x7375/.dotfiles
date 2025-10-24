{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "screenshot";
  runtimeInputs =
    with pkgs;
    [
      coreutils
      xdg-user-dirs
      libnotify
      config.me.gui.terminal
      lf
    ]
    ++ (
      if config.me.gui.displayServer == "wayland" then
        [
          hyprshot
        ]
      else
        [
          xdotool
          maim
          xclip
        ]
    );
  text =
    # bash
    ''
      time=$(date -u "+%s" | cut -c 7-)
      file="Screenshot-$(date -u +%d-%m-%Y-"$time").png"
      folder="$(xdg-user-dir SCREENSHOTS)/"

      function copy_image() {
          xclip -sel clipboard -target image/png < "$folder$file"
      }

      function send_notification() {
          local -r action=$(notify-send --icon "$folder$file" "Screenshot saved" "You can paste the image from the clipboard" -A open=open)
          if [[ $action == *open* ]]; then
              ${config.me.gui.terminal} -e lf "$(xdg-user-dir SCREENSHOTS)"
          fi
      }

      function x11_screenshot() {
          local mode=$1
          case "$mode" in
              region)
                  maim --select -u "$folder$file" && copy_image
                  ;;
              window)
                  maim -u --window "$(xdotool getactivewindow)" "$folder$file" && copy_image
                  ;;
              monitor)
                  local -r primary_geometry=$(xrandr --query | grep primary | grep -oP '\d+x\d+\+\d+\+\d+')
                  maim -g "$primary_geometry" -u "$folder$file" && copy_image
                  ;;
          esac
      }

      function wayland_screenshot() {
          local mode=$1
          local hypr_mode
          case "$mode" in
              region) hypr_mode="region" ;;
              window) hypr_mode="window" ;;
              monitor) hypr_mode="output" ;;
          esac
          hyprshot -o "$folder" -f "$file" -m "$hypr_mode" -sc
      }

      function take_screenshot() {
          local mode=$1
          if [[ $XDG_SESSION_TYPE == "x11" ]]; then
              x11_screenshot "$mode"
          else
              wayland_screenshot "$mode"
          fi && send_notification
      }

      case "$1" in
          region)
              take_screenshot "region"
              ;;
          window)
              take_screenshot "window"
              ;;
          monitor)
              take_screenshot "monitor"
              ;;
          *)
              echo "Usage: screenshot {region|window|monitor}"
              exit 1
              ;;
      esac
    '';
}
