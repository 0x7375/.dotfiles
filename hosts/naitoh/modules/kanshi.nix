{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (config.me.wm.displayServer == "wayland") {
  hj.xdg.config.files."hypr/workspaces.conf".text = ''
    workspace = 1, monitor:HDMI-1, default:true
    workspace = 2, monitor:HDMI-1
    workspace = 3, monitor:HDMI-1
    workspace = 4, monitor:HDMI-1
    workspace = 5, monitor:eDP-1
    workspace = 6, monitor:HDMI-1
    workspace = 7, monitor:HDMI-1
    workspace = 8, monitor:HDMI-1
    workspace = 9, monitor:HDMI-1
    workspace = 10, monitor:HDMI-1
  '';

  hj.xdg.config.files."kanshi/config".text =
    let
      exec = "exec ${lib.getExe pkgs.my.waybar-output}";
    in
    ''
      profile dual {
        output * enable mode preferred position 0,0
        output eDP-1 enable position 1920,0
        ${exec}
      }
      profile single_external {
        output eDP-1 disable
        output * enable mode preferred
        ${exec}
      }
      profile laptop {
        output eDP-1 enable
        ${exec}
      }
    '';
}
