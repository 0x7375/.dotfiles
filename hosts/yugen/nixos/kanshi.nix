{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf (config.me.gui.displayServer == "wayland") {
  # wayland.windowManager.hyprland.settings.workspace = lib.mkBefore [
  #   "1, monitor:HDMI-A-2, default:true"
  #   "2, monitor:HDMI-A-2"
  #   "3, monitor:HDMI-A-2"
  #   "4, monitor:HDMI-A-2"
  #   "5, monitor:HDMI-A-1"
  #   "6, monitor:HDMI-A-2"
  #   "7, monitor:HDMI-A-2"
  #   "8, monitor:HDMI-A-2"
  #   "9, monitor:HDMI-A-2"
  #   "10, monitor:HDMI-A-2"
  # ];
  #
  # services.kanshi.settings = [
  #   {
  #     profile = {
  #       name = "desktop_dual";
  #       outputs = [
  #         {
  #           criteria = "HDMI-A-1";
  #           status = "enable";
  #           mode = "1920x1080@120Hz";
  #           position = "0,0";
  #         }
  #         {
  #           criteria = "HDMI-A-2";
  #           status = "enable";
  #           mode = "1920x1080@240Hz";
  #           position = "1920,0";
  #         }
  #       ];
  #       exec = [
  #         "${lib.getExe pkgs.scripts.waybar-output}"
  #       ];
  #     };
  #   }
  #   {
  #     profile = {
  #       name = "desktop_right_only";
  #       outputs = [
  #         {
  #           criteria = "HDMI-A-2";
  #           status = "enable";
  #           mode = "1920x1080@240Hz";
  #           position = "0,0";
  #         }
  #       ];
  #       exec = [
  #         "${lib.getExe pkgs.scripts.waybar-output}"
  #       ];
  #     };
  #   }
  #   {
  #     profile = {
  #       name = "desktop_left_only";
  #       outputs = [
  #         {
  #           criteria = "HDMI-A-1";
  #           status = "enable";
  #           mode = "1920x1080@120Hz";
  #           position = "0,0";
  #         }
  #       ];
  #       exec = [
  #         "${lib.getExe pkgs.scripts.waybar-output}"
  #       ];
  #     };
  #   }
  # ];
}
