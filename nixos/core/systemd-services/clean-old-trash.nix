{ pkgs, ... }:

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
      ${pkgs.trash-cli}/bin/trash-empty 15
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
