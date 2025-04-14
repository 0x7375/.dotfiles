{
  myLib,
  config,
  lib,
  ...
}:

let
  palette = myLib.palette;
in
lib.mkIf config.me.gui.enable {
  services.polybar = {
    enable = true;
    script = "";
    settings = {
      settings = {
        screenchange.reload = true;
        pseudo.transparency = true;
      };
      "module/memory" = {
        type = "internal/memory";
        interval = 3;
        format = "ram: <label>";
        # format = "󰍛 <label>";
      };
      "bar/main" = {
        width = "100%";
        height = 35;
        radius = 0;

        background = palette.bg0_dark;
        foreground = palette.fg0;

        border.size = "0pt";

        font = [
          "Mononoki Nerd Font:pixelsize=${toString myLib.bar.font-size};4"
        ];

        padding = 1;
        module-margin = 0;

        modules.left = "nix";
        modules.center = "i3";
        modules.right = "memory battery network datetime";

        separator = "|";
        separator-padding = 1;
        separator-foreground = palette.fg0;

        enable.ipc = true;
      };
      "module/nix" = {
        type = "custom/text";
        format = "~${config.me.hostname}";
        # format = "  ";
      };
      "module/tray" = {
        type = "internal/tray";
      };
      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;

        label = rec {
          focused = {
            text = "%index%";
            foreground = palette.fg0;
            padding = 1;
          };
          unfocused = {
            text = focused.text;
            foreground = palette.bg2;
            padding = focused.padding;
          };
          visible = unfocused;
          urgent = unfocused;
        };
      };
      "module/battery" =
        let
          defaultLabel = "pow: %percentage%%";
        in
        {
          type = "internal/battery";
          battery = "BAT0";
          poll.interval = 5;
          label.charging = "pow: ~%percentage%%";
          label.discharging = defaultLabel;
          label.low = defaultLabel;
          label.full = defaultLabel;
          format.charging = "<label-charging>";
          format.discharging = "<label-discharging>";

          # format.charging = "<animation-charging> <label-charging>";
          # format.discharging = "<ramp-capacity> <label-discharging>";
          # ramp.capacity = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          # animation.charging.text = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          # animation.charging.framerate = 750;
        };
      "module/network" = {
        type = "internal/network";
        interface = "wlan0";
        label.connected = {
          text = "%essid%";
          maxlen = 8;
        };
        # label.disconnected.text = "󰤭";
        label.disconnected.text = "net: x";
        label.disconnected.foreground = palette.fg3;
        format.connected = "net: <label-connected>";

        # format.connected = "<ramp-signal> <label-connected>";
        # ramp.signal = [
        #   "󰤟"
        #   "󰤢"
        #   "󰤥"
        #   "󰤨"
        # ];
      };
      "module/datetime" = {
        type = "internal/date";
        date = "%a %d %b - %H:%M";
        interval = 1;
      };
    };
  };
}
