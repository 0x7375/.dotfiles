{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      packages = with pkgs; [
        imagemagick
        # kdePackages.kdenlive
        ffmpeg-full

        sly
        gimp
        vlc
        celluloid
        jellyfin-media-player
      ];
    };
}
