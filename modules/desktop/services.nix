{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.desktop.enable {
  systemd.user.services.devmon = {
    path = [ pkgs.libnotify ];
    serviceConfig.ExecStart =
      let
        mount = "/run/media/ayko";
      in
      lib.mkForce ''${lib.getExe' pkgs.udevil "devmon"} --exec-on-remove "notify-send 'Device %f unmounted from ${mount}' -i disk-$theme -r 9998" --exec-on-drive "notify-send 'Device %f mounted at ${mount}' -i disk-$theme -r 9999"'';
  };

  services = {
    dbus.enable = true;
    gvfs.enable = true;
    devmon.enable = true;

    ddccontrol.enable = true; # external monitor brightness control

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
          RUN+="${lib.getExe' pkgs.su "su"} ${config.me.user} -c '${lib.getExe pkgs.playerctl} pause --all-players'"
        '';
      in
      ''
        ${removeRule "bluetooth"}

        ${removeRule "sound"}
      '';

    gnome.sushi.enable = true;
  };
}
