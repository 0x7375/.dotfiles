{
  flake.modules.nixos.laptop =
    { lib, ... }:
    let
      all = map toString (lib.range 1 9);
    in
    {
      me.desktop.profiles = {
        dual = {
          primary = "HDMI-A-1";
          monitors = {
            HDMI-A-1 = {
              tags = lib.remove "5" all;
              position = {
                x = 0;
                y = 0;
              };
            };
            eDP-1 = {
              tags = [ "5" ];
              position = {
                x = 0;
                y = 1080;
              };
            };
          };
        };
        laptop = {
          primary = "eDP-1";
          monitors.eDP-1.tags = all;
        };
      };
    };
}
