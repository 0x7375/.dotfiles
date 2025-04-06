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
  };

  systemd.services."eyes-notify" = {
    script = ''
      ${
        pkgs.writeShellApplication {
          name = "eyes-notify";
          runtimeInputs = [ pkgs.libnotify ];
          text = ''
            ADDRESS=/run/user/1000/bus
            # while [[ ! -e $ADDRESS ]]; do
            #   sleep 1
            # done

            export DISPLAY=:0
            export DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS"

            notify-send "Look away" "Look away for 20 seconds." -i "eye" -t 20000
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
