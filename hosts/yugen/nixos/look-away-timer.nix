{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.enable && true) {
  systemd.timers.look-away = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20m";
      OnUnitActiveSec = "20m";
    };
  };

  systemd.services.look-away = {
    script = ''
      ${lib.getExe' pkgs.systemd "systemctl"} start look-away-notify
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.services.look-away-notify = {
    script = "${pkgs.writeShellScript "look-away-notify" ''
      ADDRESS=/run/user/${toString config.me.uid}/bus

      export DISPLAY=:0
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS"

      ${lib.getExe' pkgs.libnotify "notify-send"} "Look away" "Look away for 20 seconds." -i eye-$theme -t 20000
    ''}";
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
  };
}
