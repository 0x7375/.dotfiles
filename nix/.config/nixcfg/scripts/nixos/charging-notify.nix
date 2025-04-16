{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "charging-notify";
  runtimeInputs = with pkgs; [
    gnugrep
    acpi
    libnotify
  ];
  text = ''
    [[ $# != 1 ]] && printf '0 or 1 must be passed as an argument.\nUsage: %s 0|1\n' "$0" && exit

    export XAUTHORITY=/run/user/${toString config.me.uid}/Xauthority
    export DISPLAY=:0
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${toString config.me.uid}/bus"

    battery_charging=$1
    battery_level=$(acpi -b | grep -E "remaining|zero|until" | grep -P -o '[0-9]+(?=%)')

    if [[ $battery_charging -eq 1 ]]; then
      notify-send "Charging" "$battery_level% of battery charged." -a "charging" -i "battery-charging" -r 9991
    elif [[ $battery_charging -eq 0 ]]; then
      notify-send "Discharging" "$battery_level% of battery remaining." -a "charging" -i "battery" -r 9991
    fi
  '';
}
