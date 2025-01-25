{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  xsession.windowManager.i3.config.startup = [
    {
      command = "KEYD_SOCKET=/run/keyd/keyd.sock ${pkgs.keyd}/bin/keyd-application-mapper";
      notification = false;
    }
  ];

  xdg.configFile."keyd/app.conf" = {
    text = # toml
      ''
        [firefox]

        f7 = M-right
        f8 = M-left

        control.p = up
        control.n = down
        control.m = enter
        control.e = f6
        control.j = C-S-tab
        control.k = C-tab
        control.h = backspace
        control.w = C-backspace
        control.d = C-w
      '';
  };
}
