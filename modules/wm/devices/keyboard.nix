{
  lib,
  config,
  pkgs,
  mkNixos,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  unfree-packages = [ "via" ];

  packages = with pkgs; [
    via
    vial
  ];

  services.udev.packages = with pkgs; [
    via
    vial
  ];

  hardware.keyboard.qmk.enable = true;
})

