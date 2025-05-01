{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.gui.enable {
  environment.systemPackages = [ pkgs.xdg-desktop-portal-termfilechooser ];

  environment.sessionVariables = {
    GDK_DEBUG = "portals";
    GTK_USE_PORTAL = "1";
  };

  xdg.portal = {
    config.common = {
      "org.freedesktop.impl.portal.FileChooser" = [
        "termfilechooser"
      ];
    };
    extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
  };
}
