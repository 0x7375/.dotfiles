{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable {
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
}
