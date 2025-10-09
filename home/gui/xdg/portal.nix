{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.gui.enable {
  # xdg portal needed for global dark theme
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
