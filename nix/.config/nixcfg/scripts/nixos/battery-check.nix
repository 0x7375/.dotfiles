{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "battery-check";
  runtimeInputs = with pkgs; [
    gnugrep
    acpi
    systemd
  ];
  text = ''
    HIBERNATE_LEVEL=3
    BATTERY_DISCHARGING=$(acpi -b | grep -E "remaining|charged|zero" | { grep -c "Discharging" || true; })
    BATTERY_LEVEL=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)')

    if [ "$BATTERY_LEVEL" -le "$HIBERNATE_LEVEL" ] && [ "$BATTERY_DISCHARGING" -eq 1 ]; then
        systemctl hibernate
    fi
  '';
}
