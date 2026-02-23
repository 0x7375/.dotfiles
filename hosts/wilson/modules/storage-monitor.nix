{
  pkgs,
  config,
  ...
}:

let
  inherit (config.me) host;
in
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
        threshold_warning=90
        threshold_critical=95
        message=""
        lock_dir="/tmp/storage-monitor-locks"
        mkdir -p "$lock_dir"

        root_usage=$(df -h / | grep -v Filesystem | awk '{print $5}' | tr -d '%')
        lockfile="$lock_dir/root_$threshold_warning"

        if [[ $root_usage -ge $threshold_critical ]]; then
          message="Root filesystem at $root_usage% (CRITICAL)"
          lockfile="$lock_dir/root_$threshold_critical"
        elif [[ $root_usage -ge $threshold_warning ]]; then
          message="Root filesystem at $root_usage% (WARNING)"
        else
          rm -f "$lock_dir/root_$threshold_warning" "$lock_dir/root_$threshold_critical"
        fi

        if [[ -n $message ]]; then
          if [[ ! -f $lockfile ]]; then
            curl -d "$message" ${ntfyUrl}/status
            touch "$lockfile"
          fi
        fi
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
}
