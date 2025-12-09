{
  lib,
  pkgs,
  config,
  ...
}:

lib.mkIf config.me.wm.enable (
  lib.mkMerge [
    {

      # services.gnome.sushi.enable = true;

      packages = with pkgs; [
        imagemagick
        obs-studio
        gimp
        # kdePackages.kdenlive
        sly
        vlc
        celluloid
        # insecure because of qt5: https://github.com/nixos/nixpkgs/issues/437865
        # auto.jellyfin-media-player
        ffmpeg-full
      ];

    }
    {
      packages = with pkgs; [ calibre ];
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
    }
  ]
)
