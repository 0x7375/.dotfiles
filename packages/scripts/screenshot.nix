{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "screenshot";
  runtimeInputs = with pkgs; [
    coreutils
    xdg-user-dirs
    libnotify
    config.me.wm.terminal
    lf
    hyprshot
  ];
  text =
    # bash
    ''
      time=$(date -u "+%s" | cut -c 7-)
      file="Screenshot-$(date -u +%d-%m-%Y-"$time").png"
      folder="$(xdg-user-dir SCREENSHOTS)/"

      function send_notification() {
          local -r action=$(notify-send --icon "$folder$file" "Screenshot saved" "You can paste the image from the clipboard" -A open=open)
          if [[ $action == *open* ]]; then
              ${config.me.wm.terminalCmd} -e lf "$(xdg-user-dir SCREENSHOTS)"
          fi
      }

      function take_screenshot() {
          local mode=$1
          local hypr_mode
          case "$mode" in
              region) hypr_mode="region" ;;
              window) hypr_mode="window" ;;
              monitor) hypr_mode="output" ;;
          esac
          hyprshot -o "$folder" -f "$file" -m "$hypr_mode" -sc
          send_notification
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
