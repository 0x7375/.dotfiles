{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "powermenu";
  runtimeInputs = with pkgs; [
    systemd
    scripts.lock
    bemenu
    i3
  ];
  bashOptions = [
    "nounset"
    "pipefail"
  ];
  text = ''
    options=(kill logout shutdown reboot setup)
    if [[ -d /sys/class/power_supply/BAT0 ]]; then
      options+=(lock suspend hibernate)
    else
      options+=(windows)
    fi

    chosen="$(printf "%s\n" "''${options[@]}" | bemenu -p 'POWER')"

    case $chosen in
      "kill") ps --no-headers -u "$USER" -o pid,comm,%cpu,%mem --sort=-%mem,-%cpu | bemenu -i -p KILL | awk '{print $1}' | xargs -r kill ;;
      "lock") lock ;;
      "logout") loginctl terminate-user ${toString config.me.uid} ;;
      "suspend") systemctl suspend && lock ;;
      "hibernate") pkill 1password; systemctl hibernate ;;
      "shutdown") systemctl poweroff ;;
      "reboot") systemctl --no-wall reboot ;;
      "windows") systemctl --no-wall reboot --boot-loader-entry=auto-windows ;;
      "setup") systemctl --no-wall reboot --firmware-setup ;;
    esac
  '';
}
