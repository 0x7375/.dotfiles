{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "battery-check";
  runtimeInputs = with pkgs; [
    gnugrep
    acpi
    systemd
  ];
  text = ''
    hibernate_level=3
    battery_discharging=$(acpi -b | grep -E "remaining|charged|zero" | { grep -c "Discharging" || true; })
    battery_level=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)')

    if [ "$battery_level" -le "$hibernate_level" ] && [ "$battery_discharging" -eq 1 ]; then
        systemctl hibernate
    fi
  '';
}
