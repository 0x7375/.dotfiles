{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable {
  unfree-packages = [ "android-studio-stable" ];

  users.users.${config.me.user}.extraGroups = [ "adbusers" ];

  programs.adb.enable = true;

  packages = with pkgs; [
    # android-studio
    scrcpy
  ];
}
