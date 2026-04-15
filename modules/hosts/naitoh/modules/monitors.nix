{
  flake.nixos.naitoh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      me.desktop.monitors = {
        HDMI-A-1 = lib.remove "5" (map toString (lib.range 1 9));
        eDP-1 = [ "5" ];
      };

      tinted.files.".config/mango/config.conf".value.monitorrule = [
        "name:HDMI-A-1,scale:${toString config.me.desktop.scaling}"
        "name:eDP-1,scale:${toString config.me.desktop.scaling}"
      ];

      hj.xdg.config.files."kanshi/config".text =
        let
          exec = "exec ${lib.getExe pkgs.my.waybar-output}";
        in
        # sway
        ''
          profile dual {
            output * enable position 0,0
            output eDP-1 enable position 0,1080
            ${exec}
          }
          profile laptop {
            output eDP-1 enable
            ${exec}
          }
        '';
    };
}
