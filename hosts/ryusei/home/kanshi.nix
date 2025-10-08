{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (config.me.gui.displayServer == "wayland") {
  wayland.windowManager.hyprland.settings.workspace = lib.mkBefore [
    "1, monitor:HDMI-A-1, default:true"
    "2, monitor:HDMI-A-1"
    "3, monitor:HDMI-A-1"
    "4, monitor:HDMI-A-1"
    "5, monitor:eDP-1"
    "6, monitor:HDMI-A-1"
    "7, monitor:HDMI-A-1"
    "8, monitor:HDMI-A-1"
    "9, monitor:HDMI-A-1"
    "10, monitor:HDMI-A-1"
  ];

  services.kanshi.settings = [
    {
      profile = {
        name = "laptop_hdmi_120";
        outputs = [
          {
            criteria = "HDMI-A-1";
            status = "enable";
            mode = "1920x1080@120Hz";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            position = "0,1080";
          }
        ];
        exec = [
          "${lib.getExe pkgs.scripts.waybar-output}"
        ];
      };
    }
    {
      profile = {
        name = "laptop_hdmi_fallback";
        outputs = [
          {
            criteria = "HDMI-A-1";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            position = "0,1080";
          }
        ];
        exec = [
          "${lib.getExe pkgs.scripts.waybar-output}"
        ];
      };
    }
    {
      profile = {
        name = "laptop_only";
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
        exec = [
          "${lib.getExe pkgs.scripts.waybar-output}"
        ];
      };
    }
  ];
}
