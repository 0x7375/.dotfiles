{
  config,
  lib,
  pkgs,
  ...
}:

let

  timers =
    let
      toTimer =
        timer:
        "--timer ${toString timer.delay} ${
          lib.escapeShellArgs [
            timer.command
            timer.canceller
          ]
        }";
      idle-check = lib.getExe pkgs.scripts.idle-check;
    in
    map toTimer (
      lib.filter (timer: timer.command != null) [
        {
          delay = 600;
          command = "${idle-check} standby";
        }
        {
          delay = 30;
          command = "${idle-check} lock";
        }
        {
          delay = 2970;
          command = "${idle-check} hibernate";
        }
      ]
    );
in
lib.mkIf (config.me.gui.displayServer == "xorg") {
  systemd.user.services.xidlehook = {
    description = "xidlehook service";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    unitConfig.conditionEnvironment = [ "DISPLAY" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xidlehook}/bin/xidlehook --detect-sleep --not-when-audio ${timers}";
      Restart = "always";
    };
    wantedBy = [ "graphical-session.target" ];
  };
}
