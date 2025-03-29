{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  xsession.windowManager.i3.config.startup = [
    {
      command = "${pkgs.systemd}/bin/systemctl --user restart keyd-application-mapper";
      always = true;
      notification = false;
    }
  ];

  systemd.user.services.keyd-application-mapper = {
    Unit = {
      Description = "keyd application mapper";
    };

    Service = {
      Environment = "KEYD_SOCKET=/run/keyd/keyd.sock";
      ExecStart = "${pkgs.keyd}/bin/keyd-application-mapper";
      Restart = "always";
    };
  };

  xdg.configFile."keyd/app.conf" = {
    text =
      let
        backspace = "control.h = backspace";
        enter = "control.m = enter";
        upDown = ''
          control.p = up
          control.n = down
        '';
      in
      # toml
      ''
        # A-key and M-key (alt and meta) need to be swapped because I swap alt and windows key
        [librewolf]

        f7 = M-right
        f8 = M-left

        ${backspace}
        ${upDown}
        ${enter}
        control.e = f6
        control.j = C-tab
        control.k = C-S-tab
        control.w = C-backspace
        control.d = C-w

        [io-ente-auth]
        ${enter}
        ${upDown}
        ${backspace}
        control.e = macro(tab tab tab enter)

        [1password]
        ${enter}
        ${upDown}

        [copyq]
        control.m = macro(enter 20ms A-q)
        ${upDown}
        ${backspace}

        [legcord]
        ${enter}
        ${backspace}

        [ssh-askpass]
        ${enter}
        ${backspace}

        [polkit-gnome-authentication-agent-1]
        ${enter}
        ${backspace}
      '';
  };
}
