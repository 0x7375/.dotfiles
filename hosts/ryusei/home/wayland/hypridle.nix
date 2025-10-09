{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "wayland") {
  services.hypridle = {
    enable = true;
    settings = {
      listener =
        let
          idle-check = lib.getExe pkgs.scripts.idle-check;
        in
        [
          {
            timeout = 600;
            on-timeout = "${idle-check} standby";
          }
          {
            timeout = 630;
            on-timeout = "${idle-check} lock";
          }
          {
            timeout = 3600;
            on-timeout = "${idle-check} hibernate";
          }
        ];
    };
  };
}
