{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "xorg") {
  hj.xdg.config.files."i3/config".text = ''
    workspace "1" output "HDMI-1"
    workspace "2" output "HDMI-1"
    workspace "3" output "HDMI-1"
    workspace "4" output "HDMI-1"
    workspace "5" output "eDP-1"
    workspace "6" output "HDMI-1"
    workspace "7" output "HDMI-1"
    workspace "8" output "HDMI-1"
    workspace "9" output "HDMI-1"
    workspace "10" output "HDMI-1"
  '';

  hj.xdg.config.files."grobi.conf".value.rules =
    let
      inherit (lib) getExe';
      HDMI =
        {
          name,
          mode ? null,
          id ? null,
        }:
        {
          inherit name;
          outputs_connected = [
            "eDP-1"
            "HDMI-1${lib.optionalString (id != null) ("-" + id)}"
          ];
          configure_column = [
            "HDMI-1${lib.optionalString (mode != null) ("@" + toString mode)}"
            "eDP-1"
          ];
          atomic = true;
          primary = "HDMI-1";
          execute_after = [
            "${getExe' pkgs.i3 "i3-msg"} restart"
            "${getExe' pkgs.xorg.xset "xset"} s off -dpms"
          ];
        };
    in
    [
      # rules are evaluted in order
      (HDMI {
        name = "Home: right";
        id = "BNQ-32642-16843009-ZOWIE XL LCD-EBB7N00958SL0";
        mode = "1920x1080@240";
      })
      (HDMI {
        name = "Home: left";
        id = "ACR-1156-1930442278-Acer XF270H-";
        mode = "1920x1080@120";
      })
      (HDMI { name = "Default"; })
      {
        name = "Laptop";
        outputs_connected = [ "eDP-1" ];
        configure_single = "eDP-1";
        primary = true;
        atomic = true;
        execute_after = [
          "${getExe' pkgs.i3 "i3-msg"} restart"
          "${getExe' pkgs.xorg.xset "xset"} s on -dpms"
        ];
      }
      {
        name = "Fallback";
        configure_single = "eDP-1";
      }
    ];
}
