{
  lib,
  pkgs,
  config,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "wayland") {
  packages = [ pkgs.kanshi ];

  systemd.user.services.kanshi = {
    description = "kanshi";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.kanshi}";
      Restart = "always";
      RestartSec = 3;
    };
  };

  vars = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
