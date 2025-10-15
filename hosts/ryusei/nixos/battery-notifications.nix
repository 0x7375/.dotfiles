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
    script = ''
      ${lib.getExe' pkgs.systemd "systemctl"} start battery-notify
      ${lib.getExe' pkgs.systemd "systemctl"} start battery-check
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.battery-notify = {
    script = ''
      set +e
      ${lib.getExe pkgs.scripts.battery-notify}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
  };

  systemd.services."battery-check" = {
    script = ''
      ${lib.getExe pkgs.scripts.battery-check}
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
