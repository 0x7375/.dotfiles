{ pkgs, ... }:

{
  services.grobi = {
    enable = true;
    rules = [
      {
        name = "Base";
        outputs_connected = [ "eDP-1" ];
        configure_single = "eDP-1";
        primary = true;
        atomic = true;
        execute_after = [
          "${pkgs.i3}/bin/i3-msg restart"
        ];
      }
      {
        name = "Home";
        outputs_connected = [
          "eDP-1"
          "HDMI-1"
        ];
        configure_row = [
          "eDP-1"
          "HDMI-1"
        ];
        atomic = true;
        primary = "HDMI-1";
        execute_after = [
          "${pkgs.i3}/bin/i3-msg restart"
        ];
      }
    ];
  };
}
