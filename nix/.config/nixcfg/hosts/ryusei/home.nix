{ myLib, pkgs, ... }:

{
  imports = [
    ../../home
    ./options.nix
  ] ++ myLib.filesIn ./home;

  services.xidlehook = {
    enable = true;
    not-when-audio = true;
    detect-sleep = true;
    timers = [
      {
        delay = 600;
        command = "${pkgs.scripts.xidle-check}/bin/xidle-check standby";
      }
      {
        delay = 20;
        command = "${pkgs.scripts.xidle-check}/bin/xidle-check lock";
      }
      {
        delay = 2980;
        command = "${pkgs.scripts.xidle-check}/bin/xidle-check hibernate";
      }
    ];
  };

  xsession.windowManager.i3 = {
    config = {
      workspaceOutputAssign = [
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
          output = "HDMI-1";
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
          output = "eDP-1";
          workspace = "10";
        }
      ];
    };
  };

  services.polybar.settings."module/network".interface = "wlp3s0";
}
