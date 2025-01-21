{ pkgs, ... }:

{
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
        "${pkgs.i3}/bin/i3-msg restart"
        "${pkgs.xorg.xset}/bin/xset s off -dpms"
      ];
    }
    {
      name = "Right only";
      outputs_connected = [ "HDMI-1" ];
      configure_single = "HDMI-1@1920x1080@240";
      primary = true;
      atomic = true;
      execute_after = [
        "${pkgs.i3}/bin/i3-msg restart"
        "${pkgs.xorg.xset}/bin/xset s off -dpms"
      ];
    }
    {
      name = "Left only";
      outputs_connected = [ "HDMI-0" ];
      configure_single = "HDMI-0@1920x1080@120";
      primary = true;
      atomic = true;
      execute_after = [
        "${pkgs.i3}/bin/i3-msg restart"
        "${pkgs.xorg.xset}/bin/xset s off -dpms"
      ];
    }
    {
      name = "Fallback";
      configure_single = "HDMI-1";
    }
  ];
}
