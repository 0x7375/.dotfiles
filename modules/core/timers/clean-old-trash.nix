{
  mkNixos,
  lib,
  pkgs,
  ...
}:

mkNixos {
  systemd.timers.clean-old-trash = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  systemd.services.clean-old-trash.serviceConfig = {
    Type = "oneshot";
    User = "root";
    ExecStart = "${lib.getExe' pkgs.trash-cli " trash-empty "} 15";
  };
}
