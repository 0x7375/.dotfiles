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
        [firefox]

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

        [io.ente.auth]
        ${enter}
        ${backspace}

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

        [polkit-gnome-authentication-agent-1]
        ${enter}
        ${backspace}
      '';
  };
}
