{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  environment.systemPackages = with pkgs; [
    via
    vial
  ];

  services.udev.packages = with pkgs; [
    via
    vial
  ];

  hardware.keyboard.qmk.enable = true;
}
