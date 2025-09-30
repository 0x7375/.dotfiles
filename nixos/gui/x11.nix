{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.me) gui;
in
lib.mkIf (gui.enable && gui.displayServer == "xorg") {
  services = {
    picom = {
      enable = true;
      shadow = false;
      fade = false;
      vSync = true;
      backend = "glx";
    };

    xbanish.enable = true; # hide mouse cursor when typing

    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];

      xkb.options = "compose:ralt";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          xdo
          xclip
          xsel
          xdotool
        ];
      };
    };

  };
}
