{ pkgs, myLib, ... }:

{
  services.jellyfin = {
    enable = true;
    package = pkgs.media.jellyfin;
    group = myLib.media-group;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    media.jellyfin-web
    media.jellyfin-ffmpeg
  ];
}
