{ pkgs, myLib, ... }:

{
  services.jellyfin = {
    enable = true;
    package = pkgs.auto.jellyfin;
    group = myLib.media-group;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    auto.jellyfin-web
    auto.jellyfin-ffmpeg
  ];
}
