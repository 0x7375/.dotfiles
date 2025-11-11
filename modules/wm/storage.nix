{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable {
  packages = with pkgs; [
    gparted
    nautilus
    file-roller
    ntfs3g
  ];

  services.gvfs.enable = true;

  programs = {
    kdeconnect.enable = true;

    gnome-disks.enable = true;

    localsend = {
      enable = true;
      package = pkgs.auto.localsend;
    };

    nautilus-open-any-terminal = {
      enable = true;
      terminal = config.me.wm.terminal;
    };
  };
}
