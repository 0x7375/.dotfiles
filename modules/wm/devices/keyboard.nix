{
  lib,
  config,
  pkgs,
  mkNixos,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  packages = with pkgs; [ vial ];
  services.udev.packages = with pkgs; [ vial ];

  hardware.keyboard.qmk.enable = true;
})
