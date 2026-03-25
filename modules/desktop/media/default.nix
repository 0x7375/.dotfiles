{
  flake.shared.desktop =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        imagemagick
        # kdePackages.kdenlive
        # insecure because of qt5: https://github.com/nixos/nixpkgs/issues/437865
        # auto.jellyfin-media-player
        ffmpeg-full
      ];
    };

  flake.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      packages = with pkgs; [
        sly
        calibre
        gimp
        obs-studio
        vlc
        celluloid
        jellyfin-media-player
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
}
