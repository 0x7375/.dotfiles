{
  flake.modules.nixos.pearlman =
    {
      pkgs,
      config,
      ...
    }:
    {
      systemd.services.storage-monitor = {
        description = "Monitor storage usage";

        path = with pkgs; [
          coreutils
          curl
          gawk
        ];

        script =
          let
            ntfyUrl = config.me.services.ntfy.url;
          in
          # bash
          ''
            lock_dir="/tmp/storage-monitor-locks"
            mkdir -p "$lock_dir"

            thresholds=(95 90 80)
            declare -A threshold_labels=([95]="CRITICAL" [90]="WARNING" [80]="NOTICE")

            get_usage() { df "$1" | awk 'NR==2 {gsub(/%/, "", $5); print $5}'; }

            check_filesystem() {
              local name="$1" usage="$2" hit=""

              for t in "''${thresholds[@]}"; do
                if [[ $usage -ge $t ]]; then hit=$t; break; fi
              done

              if [[ -n $hit ]]; then
                local lockfile="$lock_dir/''${name}_''${hit}"
                if [[ ! -f $lockfile ]]; then
                  curl -d "''${name} filesystem at ''${usage}% (''${threshold_labels[$hit]})" "${ntfyUrl}/status"
                  touch "$lockfile"
                fi
              else
                for t in "''${thresholds[@]}"; do rm -f "$lock_dir/''${name}_''${t}"; done
              fi
            }

            check_filesystem "root" "$(get_usage /)"
            check_filesystem "data" "$(get_usage /data)"
          '';

        serviceConfig.Type = "oneshot";
      };

      systemd.timers.storage-monitor = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = "30min";
        };
      };
    };
}
