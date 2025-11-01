{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
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
