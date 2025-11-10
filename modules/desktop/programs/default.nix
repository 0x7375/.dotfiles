{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.desktop.enable {
  users.users.${config.me.user}.extraGroups = [ "adbusers" ];

  programs = {
    adb.enable = true;
    dconf.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 5 --keep-since 7d";
    };

    kdeconnect.enable = true;

    localsend = {
      enable = true;
      package = pkgs.auto.localsend;
    };

    nautilus-open-any-terminal = {
      enable = true;
      terminal = config.me.desktop.terminal;
    };

    gnome-disks.enable = true;
  };
}
