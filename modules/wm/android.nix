{
  lib,
  config,
  pkgs,
  mkBundle,
  ...
}:

lib.mkIf config.me.wm.enable (mkBundle {
  nixos.users.users.${config.me.user}.extraGroups = [ "adbusers" ];

  unfree-packages = [ "android-studio-stable" ];

  packages = with pkgs; [
    android-tools
    # android-studio
    scrcpy
  ];
})
