{
  lib,
  myLib,
  pkgs,
  ...
}:

{
  imports = [
    ./options.nix
  ]
  ++ (myLib.filesIn ./home)
  ++ (myLib.filesIn ../../home);

  services.xidlehook = {
    enable = true;
    not-when-audio = true;
    detect-sleep = true;
    timers = [
      {
        delay = 600;
        command = "${lib.getExe pkgs.scripts.xidle-check} standby";
      }
      {
        delay = 20;
        command = "${lib.getExe pkgs.scripts.xidle-check} lock";
      }
      {
        delay = 2980;
        command = "${lib.getExe pkgs.scripts.xidle-check} hibernate";
      }
    ];
  };

}
