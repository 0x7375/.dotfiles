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
        in
        {
          dual = {
            HDMI-A-1 = lib.remove "5" all;
            eDP-1 = [ "5" ];
          };
          laptop = {
            eDP-1 = all;
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
