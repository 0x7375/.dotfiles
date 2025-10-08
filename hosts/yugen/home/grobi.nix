{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "x11") {
  xsession.windowManager.i3.config.workspaceOutputAssign = [
    {
      output = "HDMI-1";
      workspace = "1";
    }
    {
      output = "HDMI-1";
      workspace = "2";
    }
    {
      output = "HDMI-1";
      workspace = "3";
    }
    {
      output = "HDMI-1";
      workspace = "4";
    }
    {
      output = "HDMI-0";
      workspace = "5";
    }
    {
      output = "HDMI-1";
      workspace = "6";
    }
    {
      output = "HDMI-1";
      workspace = "7";
    }
    {
      output = "HDMI-1";
      workspace = "8";
    }
    {
      output = "HDMI-1";
      workspace = "9";
    }
    {
      output = "HDMI-0";
      workspace = "10";
    }
  ];

  services.grobi.rules = [
    # rules are evaluted in order
    {
      name = "Left and right";
      outputs_connected = [
        "HDMI-0"
        "HDMI-1"
      ];
      configure_row = [
        "HDMI-0@1920x1080@120"
        "HDMI-1@1920x1080@240"
      ];
      primary = "HDMI-1";
      atomic = true;
      execute_after = [
        "${lib.getExe' pkgs.i3 "i3-msg"} restart"
        "${lib.getExe' pkgs.xorg.xset "xset"} s off -dpms"
      ];
    }
    {
      name = "Right only";
      outputs_connected = [ "HDMI-1" ];
      configure_single = "HDMI-1@1920x1080@240";
      primary = true;
      atomic = true;
      execute_after = [
        "${lib.getExe' pkgs.i3 "i3-msg"} restart"
        "${lib.getExe' pkgs.xorg.xset "xset"} s off -dpms"
      ];
    }
    {
      name = "Left only";
      outputs_connected = [ "HDMI-0" ];
      configure_single = "HDMI-0@1920x1080@120";
      primary = true;
      atomic = true;
      execute_after = [
        "${lib.getExe' pkgs.i3 "i3-msg"} restart"
        "${lib.getExe' pkgs.xorg.xset "xset"} s off -dpms"
      ];
    }
    {
      name = "Fallback";
      configure_single = "HDMI-1";
    }
  ];
}
