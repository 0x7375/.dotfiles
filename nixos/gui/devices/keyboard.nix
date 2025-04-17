{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  environment.systemPackages = [ pkgs.via ];
  services.udev.packages = [ pkgs.via ];

  hardware.keyboard.qmk.enable = true;
}
