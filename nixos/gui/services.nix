{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  systemd.user.services.devmon = {
    path = [ pkgs.libnotify ];
    serviceConfig.ExecStart =
      let
        mount = "/run/media/ayko";
      in
      lib.mkForce ''
        ${pkgs.udevil}/bin/devmon --exec-on-remove "notify-send 'Device %%f unmounted from ${mount}' -i disk -r 9998" --exec-on-drive "notify-send 'Device %%f mounted at ${mount}' -i disk -r 9999"
      '';
  };

  services = {
    dbus.enable = true;
    gvfs.enable = true;
    devmon.enable = true;

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

    gnome = {
      sushi.enable = true;
    };
  };
}
