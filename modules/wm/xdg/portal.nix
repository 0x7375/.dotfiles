{
  mkNixos,
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  xdg.portal = {
    enable = true;
    config.common."org.freedesktop.impl.portal.Settings" = "darkman";
    extraPortals = with pkgs; [ darkman ];
  };

  hj.xdg.config.files."darkman/config.yaml".text = "usegeoclue: false";
})
