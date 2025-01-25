{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "powermenu";
  runtimeInputs = with pkgs; [
    systemd
    scripts.lock
    bemenu
    i3
  ];
  text = ''
    if [[ -d /sys/class/power_supply/BAT0 ]]; then
      options=(lock logout suspend hibernate shutdown reboot setup)
    else
      options=(logout shutdown reboot windows setup)
    fi

    chosen="$(printf "%s\n" "''${options[@]}" | bemenu -p 'POWER')"

    case $chosen in
      "lock") lock ;;
      "logout") i3-msg exit ;;
      "suspend") systemctl suspend && lock ;;
      "hibernate") pkill 1password; systemctl hibernate ;;
      "shutdown") systemctl poweroff ;;
      "reboot") systemctl --no-wall reboot ;;
      "windows") systemctl --no-wall reboot --boot-loader-entry=auto-windows ;;
      "setup") systemctl --no-wall reboot --firmware-setup ;;
    esac
  '';
}
