{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "xorg") {
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
      output = "eDP-1";
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
      output = "HDMI-1";
      workspace = "10";
    }
  ];

  services.grobi.rules =
    let
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
            "HDMI-1${if id != null then "-" + id else ""}"
          ];
          configure_column = [
            "HDMI-1${if mode != null then ("@" + toString mode) else ""}"
            "eDP-1"
          ];
          atomic = true;
          primary = "HDMI-1";
          execute_after = [
            "${lib.getExe' pkgs.i3 "i3-msg"} restart"
            "${lib.getExe' pkgs.xorg.xset "xset"} s off -dpms"
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
          "${lib.getExe' pkgs.i3 "i3-msg"} restart"
          "${lib.getExe' pkgs.xorg.xset "xset"} s on -dpms"
        ];
      }
      {
        name = "Fallback";
        configure_single = "eDP-1";
      }
    ];
}
