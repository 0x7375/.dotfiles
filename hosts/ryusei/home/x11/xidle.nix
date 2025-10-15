{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "xorg") {
  services.xidlehook = {
    enable = true;
    not-when-audio = true;
    detect-sleep = true;
    timers =
      let
        idle-check = lib.getExe pkgs.scripts.idle-check;
      in
      [
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
      ];
  };

}
