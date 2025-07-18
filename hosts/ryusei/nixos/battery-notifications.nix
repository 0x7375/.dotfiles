{ config, pkgs, ... }:

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
      ${pkgs.systemd}/bin/systemctl start battery-notify
      ${pkgs.systemd}/bin/systemctl start battery-check
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.battery-notify = {
    script = ''
      ${pkgs.scripts.battery-notify}/bin/battery-notify
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
  };

  systemd.services."battery-check" = {
    script = ''
      ${pkgs.scripts.battery-check}/bin/battery-check
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
