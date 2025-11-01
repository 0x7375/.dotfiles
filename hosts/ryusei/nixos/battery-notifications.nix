{
  lib,
  config,
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
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${lib.getExe' pkgs.systemd "systemctl"} start battery-notify
        ${lib.getExe' pkgs.systemd "systemctl"} start battery-check
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.battery-notify.serviceConfig = {
    Type = "oneshot";
    User = config.me.user;
    ExecStart = lib.getExe pkgs.scripts.battery-notify;
  };

  systemd.services."battery-check".serviceConfig = {
    Type = "oneshot";
    ExecStart = lib.getExe pkgs.scripts.battery-check;
  };
}
