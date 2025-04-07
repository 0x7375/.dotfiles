{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  xsession.numlock.enable = true;

  xsession.initExtra = # bash
    ''
      ${pkgs.xset}/bin/xset s off -dpms
    '';
}
