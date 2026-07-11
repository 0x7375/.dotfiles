{
  flake.modules.nixos.laptop =
    {
      pkgs,
      config,
      ...
    }:
    {
      systemd.user.services.battery-check = {
        wantedBy = [ "default.target" ];
        path = with pkgs; [
          config.services.upower.package
          libnotify
          systemd
          my.notify
        ];
        script =
          let
            action = if config.me.hostname != "woz" then "hibernate" else "suspend";
            critical_level = if action == "hibernate" then "7" else "12";
          in
          # bash
          ''
            critical_level=${critical_level}
            full_level=90

            full_notified=false
            critical_notified=false
            action_pid=""

            upower --monitor-detail | while read -r key value; do
              case "$key" in
                "state:") state="$value" ;;
                "percentage:") 
                  percentage="''${value%\%}"
                  percentage="''${percentage%%.*}"
                  ;;
                *) continue ;;
              esac

              [[ -z "$state" || -z "$percentage" ]] && continue

              if [[ "$state" == "discharging" ]]; then
                full_notified=false

                if [[ "$percentage" -le "$critical_level" ]] && ! $critical_notified; then
                  critical_notified=true
                  notify "Very low battery" "System will ${action} in 120 seconds!" -i battery -u critical -t 120000
                  
                  (sleep 120 && systemctl ${action}) &
                  action_pid=$!
                fi
              else
                $critical_notified && {
                  critical_notified=false
                  kill "$action_pid" 2>/dev/null || true
                }

                if [[ "$percentage" -ge "$full_level" ]] && ! $full_notified; then
                  full_notified=true
                  notify "Battery Charged" "Battery is fully charged." -i "battery-4"
                fi
              fi
            done
          '';
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 10;
        };
      };
    };
}
