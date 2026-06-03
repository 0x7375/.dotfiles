{ self, ... }:

{
  flake.modules.nixos.cray =
    {
      lib,
      config,
      ...
    }:
    {
      me.desktop.monitors =
        let
          all = map toString (lib.range 1 9);
          inherit (self.lib) mkNoctaliaLayout;
        in
        {
          desktop_dual = {
            outputs = {
              HDMI-A-2 = lib.remove "5" all;
              HDMI-A-1 = [ "5" ];
            };
            noctaliaLayout = mkNoctaliaLayout {
              main = "HDMI-A-2";
              secondary = "HDMI-A-1";
            };
          };

          desktop_right_only = {
            outputs.HDMI-A-2 = all;
            noctaliaLayout = mkNoctaliaLayout { main = "HDMI-A-2"; };
          };

          desktop_left_only = {
            outputs.HDMI-A-1 = all;
            noctaliaLayout = mkNoctaliaLayout { main = "HDMI-A-1"; };
          };
        };

      hj.xdg.config.files."kanshi/config".text =
        let
          script = lib.getExe config.me.desktop.monitorScript;
        in
        # sway
        ''
          profile desktop_dual {
            output HDMI-A-1 enable mode 1920x1080@120Hz position 0,0
            output HDMI-A-2 enable mode 1920x1080@240Hz position 1920,0
            exec ${script} desktop_dual
          }
          profile desktop_right_only {
            output HDMI-A-2 enable mode 1920x1080@240Hz position 0,0
            exec ${script} desktop_right_only
          }
          profile desktop_left_only {
            output HDMI-A-1 enable mode 1920x1080@120Hz position 0,0
            exec ${script} desktop_left_only
          }
        '';
    };
}
