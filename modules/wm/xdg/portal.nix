{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable {
  # xdg portal needed for global dark theme
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
