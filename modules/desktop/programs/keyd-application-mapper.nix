{
  flake.modules.nixos.desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      me.desktop.startup.keyd-application-mapper = {
        cmd = "${lib.getExe' pkgs.systemd "systemctl"} --user restart keyd-application-mapper";
        always = true;
      };

      systemd.user.services.keyd-application-mapper = {
        description = "keyd application mapper";
        path = [ pkgs.keyd ];

        serviceConfig = {
          ExecStart = "${lib.getExe' pkgs.keyd "keyd-application-mapper"}";
          Restart = "always";
        };
      };

      hj.xdg.config.files."keyd/app.conf".text =
        let
          default =
            # toml
            ''
              control.h = backspace
              control.p = up
              control.n = down
              control.m = enter
              f7 = A-right
              f8 = A-left
              control.j = C-tab
              control.k = C-S-tab
              control.w = C-backspace
              control.d = C-w
              alt.f = C-right
              alt.b = C-left
            '';

          apps = [
            "vesktop"
            "discord"
            "zen"
          ];
        in
        # toml
        ''
          [${config.me.desktop.browser}]
          ${default}
          control.e = f6

          [zen]
          control.e = f6
          # make fullscreen toggle compact mode aswell
          meta.f = macro(A-c M-f)

          ${builtins.concatStringsSep "\n\n" (map (app: "[${app}]\n${default}") apps)}
        '';
    };
}
