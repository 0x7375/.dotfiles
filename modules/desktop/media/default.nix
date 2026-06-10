{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      persistUser.directories = [
        ".local/share/jellyfin-desktop"
      ];

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
