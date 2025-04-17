{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "battery-notify";
  runtimeInputs = with pkgs; [
    gnugrep
    acpi
    libnotify
    systemd
  ];
  text = ''
    export DISPLAY=:0
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${toString config.me.uid}/bus"

    warning_level=15
    full_level=90

    empty_file=/tmp/batteryempty
    full_file=/tmp/batteryfull

    battery_discharging=$(acpi -b | grep -E "remaining|charged|zero" | { grep -c "Discharging" || true; })
    battery_level=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)')

    if [[ $battery_discharging -eq 1 ]] && [[ -f $full_file ]]; then
        rm $full_file
    elif [[ $battery_discharging -eq 0 ]] && [[ -f $empty_file ]]; then
        rm $empty_file
    fi

    if [[ $battery_level -ge $full_level && $battery_discharging -eq 0 && ! -f $full_file ]]; then
        notify-send "Battery Charged" "Battery is fully charged." -i "battery-full" -a "charged" -r 9991
        touch $full_file
    elif [[ $battery_level -le $warning_level ]] && [ $battery_discharging -eq 1 ] && [ ! -f $empty_file ]; then
        notify-send "Low Battery" "$battery_level% of battery remaining." -u critical -i "battery-low" -a "alert" -r 9991
        touch $empty_file
    fi
  '';
}
