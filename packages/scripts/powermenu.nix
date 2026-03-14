{
  config,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "powermenu";
  runtimeInputs = with pkgs; [
    systemd
    my.lock
    bemenu
    procps
  ];
  bashOptions = [
    "nounset"
    "pipefail"
  ];
  text = # bash
    ''
      options=(kill logout hibernate shutdown reboot setup)
      if [[ -d /sys/class/power_supply/BAT0 ]]; then
        options+=(lock)
      else
        options+=(windows)
      fi

      chosen="$(printf "%s\n" "''${options[@]}" | bemenu -p 'POWER')"

      case $chosen in
        "kill") ps --no-headers -u "$USER" -o comm,%mem,%cpu --sort=-%mem,-%cpu |\
          awk '{$1=$1}1' |\
          awk '!seen[$1]++' | \
          bemenu -i -p KILL |\
          awk '{print $1}' |\
          xargs -r pkill
        ;;
        "lock") lock ;;
        "logout") loginctl terminate-user ${toString config.me.uid} ;;
        "hibernate") systemctl hibernate ;;
        "shutdown") systemctl poweroff ;;
        "reboot") systemctl --no-wall reboot ;;
        "windows")
          ENTRY=$(efibootmgr | grep -i "windows" | grep -oP "Boot\K[0-9A-F]+" | head -1)
          sudo efibootmgr --bootnext "$ENTRY" && systemctl --no-wall reboot
        ;;
        "setup") systemctl --no-wall reboot --firmware-setup ;;
      esac
    '';
}
