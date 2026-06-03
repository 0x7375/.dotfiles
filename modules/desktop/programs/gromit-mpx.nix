{
  flake.modules.nixos.desktop =
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

      # me.desktop =
      #   let
      #     gromit = lib.getExe pkgs.gromit-mpx;
      #   in
      #   {
      #     startup.gromit = gromit;
      #
      #     bindings = {
      #       "Mod+o" = "${gromit} --toggle";
      #       "Mod+Shift+o" = "${gromit} --clear";
      #       "Alt+Shift+o" = "${gromit} --undo";
      #       "Shift+F9" = "${gromit} --toggle";
      #     };
      #   };

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
