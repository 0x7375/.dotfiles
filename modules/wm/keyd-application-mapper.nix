{
  flake.nixos.wm =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      me.wm.startup.keyd-application-mapper = {
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
              f7 = A-right
              f8 = A-left
              control.j = C-tab
              control.k = C-S-tab
              control.w = C-backspace
              control.d = C-w
              alt.f = C-right
              alt.b = C-left
            '';

          defaultWithEnter = default + "\ncontrol.m = enter";

          apps = [
            "vesktop"
            "discord"
          ];

          appConfigs = builtins.concatStringsSep "\n\n" (map (app: "[${app}]\n${defaultWithEnter}") apps);
        in
        # toml
        ''
          # arc raiders
          [steam-app-1808500]
          1 = 1
          2 = 2
          3 = 3
          4 = 4

          [${config.me.wm.browser}]
          ${defaultWithEnter}
          control.e = f6

          # make fullscreen toggle compact mode aswell
          meta.f = macro(A-c M-f)

          [copyq]
          ${default}
          control.m = macro(enter 20ms M-q)

          ${appConfigs}
        '';
    };
}
