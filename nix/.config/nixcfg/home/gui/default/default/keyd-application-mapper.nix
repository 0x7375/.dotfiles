{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  systemd.user.services.keyd-application-mapper = {
    Unit = {
      Description = "Keyd application specific remapping daemon";
      Documentation = "man:keyd-application-mapper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Environment = "KEYD_SOCKET=/run/keyd/keyd.sock";

      ExecStart = "${pkgs.keyd}/bin/keyd-application-mapper";
      Restart = "on-failure";
      OOMPolicy = "continue";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  xdg.configFile."keyd/app.conf" = {
    text = # toml
      ''
        [firefox]

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
