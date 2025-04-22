{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.enable && config.me.keyd.enable) {
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
        default =
          # toml
          ''
            control.h = backspace
            control.p = up
            control.n = down
            # alt and meta need to be swapped because I swap alt and super key
            f7 = M-right
            f8 = M-left
            control.j = C-tab
            control.k = C-S-tab
            control.w = C-backspace
            control.d = C-w
            meta.f = C-right
            meta.b = C-left
          '';

        defaultWithEnter = default + "\ncontrol.m = enter";

        apps = [
          "1password"
          "discord"
          "ssh-askpass"
          "polkit-gnome-authentication-agent-1"
          "spotify"
        ];

        appConfigs = builtins.concatStringsSep "\n\n" (map (app: "[${app}]\n${defaultWithEnter}") apps);
      in
      # toml
      ''
        [librewolf]
        ${defaultWithEnter}
        control.e = f6

        [io-ente-auth]
        ${defaultWithEnter}
        control.e = macro(tab tab tab enter)

        [copyq]
        ${default}
        control.m = macro(enter 20ms A-q)

        ${appConfigs}
      '';
  };
}
