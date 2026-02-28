{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "xorg") {
  systemd.user.services.xidlehook = {
    description = "xidlehook service";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = [ "DISPLAY" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${lib.getExe pkgs.xidlehook} --detect-sleep --not-when-audio \
          --timer 600 "xset dpms force standby" "" \
          --timer 300 "systemctl hibernate" ""
      '';
      Restart = "always";
    };
    wantedBy = [ "graphical-session.target" ];
  };
}
