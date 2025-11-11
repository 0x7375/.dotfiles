{
  lib,
  pkgs,
  config,
  ...
}:

lib.mkIf config.me.wm.enable {
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
