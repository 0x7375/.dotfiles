{ self, ... }:

{
  flake.modules.nixos.naitoh =
    {
      config,
      lib,
      ...
    }:
    {
      me.desktop.monitors =
        let
          all = map toString (lib.range 1 9);
          inherit (self.lib) mkNoctaliaLayout;
        in
        {
          dual = {
            outputs = {
              HDMI-A-1 = lib.remove "5" all;
              eDP-1 = [ "5" ];
            };
            noctaliaLayout = mkNoctaliaLayout {
              main = "HDMI-A-1";
              secondary = "eDP-1";
            };
          };
          laptop = {
            outputs.eDP-1 = all;
            noctaliaLayout = mkNoctaliaLayout { main = "eDP-1"; };
          };
        };

      hj.xdg.config.files."kanshi/config".text =
        let
          script = lib.getExe config.me.desktop.monitorScript;
        in
        # sway
        ''
          profile dual {
            output * enable position 0,0
            output eDP-1 enable position 0,1080
            exec ${script} dual
          }
          profile laptop {
            output eDP-1 enable
            exec ${script} laptop
          }
        '';
    };
}
