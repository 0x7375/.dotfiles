{
  flake.nixos.naitoh =
    {
      lib,
      pkgs,
      ...
    }:
    {
      systemd.timers.battery-timer = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnUnitActiveSec = "1m";
        };
      };

      systemd.services.battery-timer = {
        script = ''
          ${lib.getExe' pkgs.systemd "systemctl"} start battery-notify
          ${lib.getExe' pkgs.systemd "systemctl"} start battery-check
        '';
        serviceConfig.Type = "oneshot";
        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.battery-notify = {
        path = with pkgs; [
          gnugrep
          acpi
          libnotify
          systemd
        ];
        script = ''
          warning_level=15
          full_level=90

          empty_file=/tmp/batteryempty
          full_file=/tmp/batteryfull

          battery_discharging=$(acpi -b | grep -E "remaining|charged|zero" | grep -c "Discharging" || true)
          battery_level=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)' || echo 0)

          if [[ $battery_discharging -eq 1 ]] && [[ -f $full_file ]]; then
              rm $full_file
          elif [[ $battery_discharging -eq 0 ]] && [[ -f $empty_file ]]; then
              rm $empty_file
          fi

          if [[ $battery_level -ge $full_level && $battery_discharging -eq 0 && ! -f $full_file ]]; then
              notify-send "Battery Charged" "Battery is fully charged." -i "battery-full" -a "charged" -r 9991
              touch $full_file
          elif [[ $battery_level -le $warning_level ]] && [[ $battery_discharging -eq 1 ]] && [[ ! -f $empty_file ]]; then
              notify-send "Low Battery" "$battery_level% of battery remaining." -u critical -i "battery-low" -r 9991
              touch $empty_file
          fi
        '';
        serviceConfig.Type = "oneshot";
      };

      systemd.services."battery-check" = {
        path = with pkgs; [
          gnugrep
          acpi
          systemd
        ];
        script = ''
          hibernate_level=3

          battery_discharging=$(acpi -b | grep -E "remaining|charged|zero" | grep -c "Discharging" || true)
          battery_level=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)' || echo 0)

          if [[ $battery_level -le $hibernate_level ]] && [[ $battery_discharging -eq 1 ]]; then
              systemctl hibernate
          fi
        '';
        serviceConfig.Type = "oneshot";
      };
    };
}
