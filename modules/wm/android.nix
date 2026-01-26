{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable {
  unfree-packages = [ "android-studio-stable" ];

  users.users.${config.me.user}.extraGroups = [ "adbusers" ];

  packages = with pkgs; [
    android-tools
    # android-studio
    scrcpy
  ];
}
