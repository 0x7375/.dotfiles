{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  systemd.timers."eyes-timer" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20m";
      OnUnitActiveSec = "20m";
      Unit = "eyes-timer.service";
    };
  };

  systemd.services."eyes-timer" = {
    script = ''
      ${pkgs.systemd}/bin/systemctl start eyes-notify
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services."eyes-notify" = {
    script = ''
      ${
        pkgs.writeShellApplication {
          name = "eyes-notify";
          runtimeInputs = [ pkgs.libnotify ];
          text = ''
            export DISPLAY=:0
            export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

            notify-send "Look away" "Look away for 20 seconds." -i "eye"
          '';
        }
      }/bin/eyes-notify
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
  };
}
