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
        gimp
        vlc
        celluloid
        jellyfin-media-player
      ];
    };
}
