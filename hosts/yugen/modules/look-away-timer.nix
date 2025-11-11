{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf (config.me.wm.enable && true) {
  systemd.timers.look-away = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20m";
      OnUnitActiveSec = "20m";
    };
  };

  systemd.services.look-away.serviceConfig = {
    Type = "oneshot";
    ExecStart = "${lib.getExe' pkgs.systemd "systemctl"} start look-away-notify";
  };

  systemd.services.look-away-notify = {
    script = ''
      ADDRESS=/run/user/${toString config.me.uid}/bus

      export DISPLAY=:0
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS"

      ${lib.getExe' pkgs.libnotify "notify-send"} "Look away" "Look away for 20 seconds." -i eye -t 20000
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
  };
}
