{
  flake.modules.nixos.laptop =
    {
      pkgs,
      config,
      ...
    }:
    {
      systemd.user.timers.battery-check = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnUnitActiveSec = "1m";
        };
      };

      systemd.user.services.battery-check = {
        path = with pkgs; [
          gnugrep
          acpi
          libnotify
          systemd
          my.notify
        ];
        script =
          let
            action = if config.me.hostname != "woz" then "hibernate" else "suspend";
          in
          # bash
          ''
            critical_level=7
            full_level=90

            critical_file=/tmp/batterycritical
            full_file=/tmp/batteryfull

            is_discharging() { acpi -b | grep -q "Discharging"; }

            battery_level=$(acpi -b | grep -E "remaining|charged|zero" | grep -P -o '[0-9]+(?=%)' || echo 0)

            is_discharging && rm -f $full_file

            if [[ $battery_level -ge $full_level && ! -f $full_file ]] && ! is_discharging; then
                notify "Battery Charged" "Battery is fully charged." -i "battery-4"
                touch $full_file
            fi

            if [[ $battery_level -le $critical_level ]] && is_discharging; then
              notify "Very low battery" "System will ${action} in 120 seconds!" -i battery -u critical -t 120000

              sleep 120

              if is_discharging; then
                systemctl ${action}
              else
                rm $critical_file
              fi
            fi
          '';
        serviceConfig.Type = "oneshot";
      };
    };
}
