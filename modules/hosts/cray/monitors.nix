{
  flake.nixos.cray =
    {
      pkgs,
      lib,
      ...
    }:
    {
      me.desktop.monitors = {
        HDMI-A-2 = lib.remove "5" (map toString (lib.range 1 9));
        HDMI-A-1 = [ "5" ];
      };

      hj.xdg.config.files."kanshi/config".text =
        let
          exec = "exec ${lib.getExe pkgs.my.waybar-output}";
        in
        # sway
        ''
          profile desktop_dual {
            output HDMI-A-1 enable mode 1920x1080@120Hz position 0,0
            output HDMI-A-2 enable mode 1920x1080@240Hz position 1920,0
            ${exec}
          }
          profile desktop_right_only {
            output HDMI-A-2 enable mode 1920x1080@240Hz position 0,0
            ${exec}
          }
          profile desktop_left_only {
            output HDMI-A-1 enable mode 1920x1080@120Hz position 0,0
            ${exec}
          }
        '';
    };
}
