{ myLib, pkgs, ... }:

{
  imports = [
    ../../home
    ./options.nix
  ] ++ myLib.filesIn ./home;

  xsession.windowManager.i3.config = {
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
  };

  services.polybar.settings."module/network".interface = "wlp4s0";
}
