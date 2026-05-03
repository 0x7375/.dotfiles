{ self, ... }:

{
  flake.nixos.naitoh =
    {
      lib,
      pkgs,
      ...
    }:
    {
      systemd.user.timers.battery-timer = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnUnitActiveSec = "1m";
        };
      };

      systemd.user.services.battery-timer = {
        script = ''
          ${lib.getExe' pkgs.systemd "systemctl"} start --user battery-notify
          ${lib.getExe' pkgs.systemd "systemctl"} start --user battery-check
        '';
        serviceConfig.Type = "oneshot";
        wantedBy = [ "multi-user.target" ];
      };

      systemd.user.services.battery-notify = {
        path = with pkgs; [
          gnugrep
          acpi
          libnotify
          systemd
        ];
        script =
          let
            mkToast = self.lib.noctalia.mkToast { inherit pkgs lib; };
          in

          ''
            warning_level=15
            full_level=90

            empty_file=/tmp/batteryempty
            full_file=/tmp/batteryfull

            battery_discharging=$(acpi -b | grep -c "Discharging")
            battery_level=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)' || echo 0)

            if [[ $battery_discharging -eq 1 ]] && [[ -f $full_file ]]; then
                rm $full_file
            elif [[ $battery_discharging -eq 0 ]] && [[ -f $empty_file ]]; then
                rm $empty_file
            fi

            if [[ $battery_level -ge $full_level && $battery_discharging -eq 0 && ! -f $full_file ]]; then
                ${mkToast {
                  title = "Battery Charged";
                  body = "Battery is fully charged.";
                  icon = "battery-4";
                }}
                touch $full_file
            elif [[ $battery_level -le $warning_level ]] && [[ $battery_discharging -eq 1 ]] && [[ ! -f $empty_file ]]; then
                ${mkToast {
                  title = "Low battery";
                  body = "$battery_level% of battery remaining.";
                  type = "error";
                }}
                touch $empty_file
            fi
          '';
        serviceConfig.Type = "oneshot";
      };

      systemd.user.services."battery-check" = {
        path = with pkgs; [
          gnugrep
          acpi
          systemd
        ];
        script =
          let
            mkToast = self.lib.noctalia.mkToast { inherit pkgs lib; };
          in
          ''
            hibernate_level=5

            is_discharging() {
              acpi -b | grep -q "Discharging"
            }

            battery_level=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)' || echo 0)

            if [[ $battery_level -le $hibernate_level ]] && is_discharging; then
              ${mkToast {
                title = "Very low battery";
                body = "System will hibernate in 120 seconds!";
                type = "error";
              }}

              sleep 120

              is_discharging && systemctl hibernate
            fi
          '';
        serviceConfig.Type = "oneshot";
      };
    };
}
