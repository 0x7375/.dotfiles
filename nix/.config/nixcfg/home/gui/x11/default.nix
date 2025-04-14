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

  xdg.configFile."zsh/.zshrc".text =
    lib.mkBefore ''[[ $(tty) == "/dev/tty1" ]] && exec startx &> /dev/null'';
}
