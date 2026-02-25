{
  lib,
  config,
  mkNixos,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  packages = with pkgs; [
    nemo
    ntfs3g
    exfat
  ];

  programs.kdeconnect.enable = true;
  me.wm.startup.kdeconnect = lib.getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator";
})
