{
  config,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "powermenu";
  runtimeInputs = with pkgs; [
    systemd
    scripts.lock
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
        options+=(lock suspend)
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
        "suspend") systemctl suspend && lock ;;
        "hibernate") pkill 1password; systemctl hibernate ;;
        "shutdown") systemctl poweroff ;;
        "reboot") systemctl --no-wall reboot ;;
        "windows") systemctl --no-wall reboot --boot-loader-entry=auto-windows ;;
        "setup") systemctl --no-wall reboot --firmware-setup ;;
      esac
    '';
}
