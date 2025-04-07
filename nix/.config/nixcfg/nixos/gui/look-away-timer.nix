{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  systemd.timers."look-away" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20m";
      OnUnitActiveSec = "20m";
      Unit = "look-away.service";
    };
  };

  systemd.services."look-away" = {
    script = ''
      ${pkgs.systemd}/bin/systemctl start look-away-notify
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.services."look-away-notify" = {
    script = ''
      ${pkgs.writeShellScriptBin "look-away-notify" ''
        ADDRESS=/run/user/1000/bus
        # while [[ ! -e $ADDRESS ]]; do
        #   sleep 1
        # done

        export DISPLAY=:0
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS"

        ${pkgs.libnotify}/bin/notify-send "Look away" "Look away for 20 seconds." -i "eye" -t 20000
      ''}/bin/look-away-notify
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
  };
}
