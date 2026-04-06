{
  flake.shared.desktop =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        imagemagick
        # kdePackages.kdenlive
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
