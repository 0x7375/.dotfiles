{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  services = {
    dbus.enable = true;
    gvfs.enable = true; # trash bin support

    ddccontrol.enable = true; # external monitor brightness control

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

    libinput = {
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0";
      };
      enable = true;
    };

    udev.extraRules = # bash
      let
        removeRule = subsystem: ''
          ACTION=="remove", \
          SUBSYSTEM=="${subsystem}", \
          ENV{DISPLAY}=":0", \
          ENV{XAUTHORITY}="/run/user/${toString config.me.uid}/Xauthority", \
          RUN+="${pkgs.su}/bin/su ${config.me.user} -c '${pkgs.playerctl}/bin/playerctl pause --all-players'"
        '';
      in
      ''
        ${removeRule "bluetooth"}

        ${removeRule "sound"}
      '';
  };
}
