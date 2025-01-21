{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  services = {
    dbus.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
    gvfs.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    picom = {
      enable = true;
      shadow = false;
      fade = false;
      vSync = true;
      backend = "glx";
    };

    xbanish.enable = true;

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

      displayManager.sessionCommands = ''
        ${pkgs.autorandr}/bin/autorandr --change
      '';
    };

    libinput = {
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0";
      };
      enable = true;
    };

    udev.extraRules = # bash
      ''
        ACTION=="remove", \
        SUBSYSTEM=="sound", \
        ENV{DISPLAY}=":0", \
        ENV{XAUTHORITY}="/home/${config.me.user}/.Xauthority", \
        RUN+="${pkgs.su}/bin/su ${config.me.user} -c '${pkgs.playerctl}/bin/playerctl pause --all-players'"

        ACTION=="remove", \
        SUBSYSTEM=="bluetooth", \
        ENV{DISPLAY}=":0", \
        ENV{XAUTHORITY}="/home/${config.me.user}/.Xauthority", \
        RUN+="${pkgs.su}/bin/su ${config.me.user} -c '${pkgs.playerctl}/bin/playerctl pause --all-players'"

        ACTION=="change", \
        SUBSYSTEM=="drm", \
        HOTPLUG=="1", \
        RUN+="${pkgs.autorandr}/bin/autorandr -c && ${pkgs.i3}/bin/i3-msg restart"
      '';

    displayManager = {
      ly = {
        enable = true;
        settings = {
          hide_key_hints = true;
          clear_password = true;
        };
      };
      defaultSession = "none+i3";
    };
  };
}
