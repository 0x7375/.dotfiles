{
  lib,
  mkBundle,
  pkgs,
  config,
  ...
}:

lib.mkIf config.me.wm.enable (mkBundle {
  packages = with pkgs; [
    imagemagick
    # kdePackages.kdenlive
    # insecure because of qt5: https://github.com/nixos/nixpkgs/issues/437865
    # auto.jellyfin-media-player
    ffmpeg-full
  ];

  nixos = {
    packages = with pkgs; [
      sly
      calibre
      gimp
      obs-studio
      vlc
      celluloid
    ];
    # opening calibre ports
    networking.firewall = {
      allowedTCPPorts = [ 9090 ];
      allowedUDPPorts = [
        54982
        54982
        48123
        39001
        44044
        59678
      ];
    };
  };
})

