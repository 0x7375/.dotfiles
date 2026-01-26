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
      ExecStart =
        let
          idle-check = lib.getExe pkgs.my.idle-check;
        in
        ''
          ${pkgs.xidlehook}/bin/xidlehook --detect-sleep --not-when-audio \
            --timer 600 \
              "${idle-check} standby" "" \
            --timer 30 \
              "${idle-check} lock" "" \
            --timer 2970 \
              "${idle-check} hibernate" ""
        '';
      Restart = "always";
    };
    wantedBy = [ "graphical-session.target" ];
  };
}
