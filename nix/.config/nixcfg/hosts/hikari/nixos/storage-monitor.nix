{
  pkgs,
  myLib,
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
    script = ''
      THRESHOLD_WARNING=90
      THRESHOLD_CRITICAL=95
      MESSAGE=""
      LOCK_DIR="/tmp/storage-monitor-locks"

      ROOT_USAGE=$(df -h / | grep -v Filesystem | awk '{print $5}' | tr -d '%')
      LOCKFILE="$LOCK_DIR/root_$THRESHOLD_WARNING"

      if [ "$ROOT_USAGE" -ge "$THRESHOLD_CRITICAL" ]; then
        MESSAGE="ROOT filesystem at $ROOT_USAGE% (CRITICAL)\\n"
        LOCKFILE="$LOCK_DIR/root_$THRESHOLD_CRITICAL"
      elif [ "$ROOT_USAGE" -ge "$THRESHOLD_WARNING" ]; then
        MESSAGE="ROOT filesystem at $ROOT_USAGE% (WARNING)\\n"
      else
        rm -f "$LOCK_DIR/root_$THRESHOLD_WARNING" "$LOCK_DIR/root_$THRESHOLD_CRITICAL"
      fi

      if [ -n "$MESSAGE" ]; then
        if [ ! -f "$LOCKFILE" ]; then
          curl -d "$MESSAGE" http://${myLib.network.lan.addr.server}:8719/status
          touch "$LOCKFILE"
        fi
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.storage-monitor = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
    };
  };
}
