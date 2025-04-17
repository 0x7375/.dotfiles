{ pkgs, ... }:

{
  services.grobi.rules =
    let
      HDMI-common =
        {
          rate ? null,
        }:
        {
          name = "HDMI${if rate != null then ": " + toString rate + "hz" else ""}";
          outputs_connected = [
            "eDP-1"
            "HDMI-1"
          ];
          configure_column = [
            "HDMI-1${if rate != null then "@1920x1080@" + toString rate else ""}"
            "eDP-1"
          ];
          atomic = true;
          primary = "HDMI-1";
          execute_after = [
            "${pkgs.i3}/bin/i3-msg restart"
            "${pkgs.xorg.xset}/bin/xset s off -dpms"
          ];
        };
      HDMI-240 = HDMI-common { rate = 240; };
      HDMI-120 = HDMI-common { rate = 120; };
      HDMI = HDMI-common { };
    in
    [
      # rules are evaluted in order
      HDMI-240
      HDMI-120
      HDMI
      {
        name = "Laptop";
        outputs_connected = [ "eDP-1" ];
        configure_single = "eDP-1";
        primary = true;
        atomic = true;
        execute_after = [
          "${pkgs.i3}/bin/i3-msg restart"
        ];
      }
      {
        name = "Fallback";
        configure_single = "eDP-1";
      }
    ];
}
