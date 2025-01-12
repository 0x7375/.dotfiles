{ pkgs, ... }:

{
  systemd.timers."trash-old" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "trash-old.service";
    };
  };

  systemd.services."trash-old" = {
    script = ''
      ${pkgs.trash-cli}/bin/trash-empty 15
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
