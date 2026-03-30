{
  flake.nixos.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          inherit (final.unstable) gromit-mpx;
        })
      ];

      me.desktop =
        let
          gromit = lib.getExe pkgs.gromit-mpx;
        in
        {
          bindings = {
            "Mod+o" = "${gromit} --toggle";
            "Mod+Shift+o" = "${gromit} --clear";
            "Alt+Shift+o" = "${gromit} --undo";
            F9 = "${gromit} --toggle";
          };
        };

      tinted.files.".config/hypr/hyprland.conf".text =
        # hyprlang
        ''
          workspace = special:gromit, gapsin:0, gapsout:0, on-created-empty:${lib.getExe pkgs.gromit-mpx} -a

          bind = SUPER, o, togglespecialworkspace, gromit
          bind = , F9, togglespecialworkspace, gromit

          windowrulev2 = noblur, class:^(Gromit-mpx)$
          windowrulev2 = opacity 1 override 1 override, class:^(Gromit-mpx)$
          windowrulev2 = noshadow, class:^(Gromit-mpx)$
          windowrulev2 = suppressevent fullscreen, class:^(Gromit-mpx)$
          windowrulev2 = size 100% 100%, class:^(Gromit-mpx)$
        '';

      hj.xdg.config.files."gromit-mpx.ini" = {
        generator = lib.generators.toINI { };
        value = {
          General.ShowIntroOnStartup = false;
          Drawing.Opacity = 0.75;
        };
      };

      hj.xdg.config.files."gromit-mpx.cfg".text = ''
        "red pen" = PEN (size=5 color="red");
        "red rect" = RECT (size=5 color="red");
        "red smooth" = SMOOTH (size=5 color="red" simplify=10 snap=30);
        "red arrow" = PEN (size=5 color="red" arrowsize=2);
        "green pen" = PEN (size=5 color="green");
        "green rect" = RECT (size=5 color="green");
        "green smooth" = SMOOTH (size=5 color="green" simplify=10 snap=30);
        "green arrow" = PEN (size=5 color="green" arrowsize=2);
        "eraser" = ERASER (size=75);

        "default" = "red pen";
        "default"[SHIFT] = "red rect";
        "default"[CONTROL] = "red smooth";
        "default"[ALT] = "red arrow";
        "default"[Button2] = "green pen";
        "default"[SHIFT, Button2] = "green rect";
        "default"[CONTROL, Button2] = "green smooth";
        "default"[ALT, Button2] = "green arrow";
        "default"[Button3] = "eraser";
      '';
    };
}
