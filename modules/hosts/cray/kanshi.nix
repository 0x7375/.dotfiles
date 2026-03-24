{
  flake.nixos.cray =
    {
      pkgs,
      lib,
      ...
    }:
    {
      hj.xdg.config.files."hypr/workspaces.conf".text = ''
        workspace = 1, monitor:HDMI-A-2, default:true
        workspace = 2, monitor:HDMI-A-2
        workspace = 3, monitor:HDMI-A-2
        workspace = 4, monitor:HDMI-A-2
        workspace = 5, monitor:HDMI-A-1
        workspace = 6, monitor:HDMI-A-2
        workspace = 7, monitor:HDMI-A-2
        workspace = 8, monitor:HDMI-A-2
        workspace = 9, monitor:HDMI-A-2
        workspace = 10, monitor:HDMI-A-2
      '';

      hj.xdg.config.files."kanshi/config".text =
        let
          exec = "exec ${lib.getExe pkgs.my.waybar-output}";
        in
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
