{
  flake.modules.nixos.cray =
    { lib, ... }:
    let
      all = map toString (lib.range 1 9);
    in
    {
      me.desktop.modes = {
        DP-2 = "1920x1080@120Hz";
        HDMI-A-2 = "1920x1080@240Hz";
      };

      me.desktop.profiles = {
        desktop_dual = {
          primary = "HDMI-A-2";
          monitors = {
            HDMI-A-2 = {
              tags = lib.remove "5" all;
              position = {
                x = 1920;
                y = 0;
              };
            };
            DP-2 = {
              tags = [ "5" ];
              position = {
                x = 0;
                y = 0;
              };
            };
          };
        };
        desktop_right_only = {
          primary = "HDMI-A-2";
          monitors.HDMI-A-2.tags = all;
        };
        desktop_left_only = {
          primary = "DP-2";
          monitors.DP-2.tags = all;
        };
      };
    };
}
