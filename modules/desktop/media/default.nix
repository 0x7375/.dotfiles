{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      persistUser.directories = [
        ".local/share/jellyfin-desktop"
        ".local/share/nl.jknaapen.fladder"
      ];

      unfree-packages = [
        "mdk-sdk"
      ];

      packages = with pkgs; [
        imagemagick
        # kdePackages.kdenlive
        ffmpeg-full

        sly
        gimp
        celluloid
        jellyfin-media-player
        fladder
      ];
    };
}
