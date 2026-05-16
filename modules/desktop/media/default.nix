{
  flake.modules.generic.desktop =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        imagemagick
        # kdePackages.kdenlive
        ffmpeg-full
      ];
    };

  flake.modules.nixos.desktop =
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
