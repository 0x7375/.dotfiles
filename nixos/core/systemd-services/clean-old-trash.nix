{ lib, pkgs, ... }:

{
  systemd.timers.clean-old-trash = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  systemd.services.clean-old-trash = {
    script = ''
      ${lib.getExe' pkgs.trash-cli "trash-empty"} 15
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
