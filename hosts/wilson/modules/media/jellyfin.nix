{ pkgs, config, ... }:

{
  services.jellyfin = {
    enable = true;
    package = pkgs.auto.jellyfin;
    group = config.me.mediaGroup;
    openFirewall = true;
  };

  packages = with pkgs; [
    auto.jellyfin-web
    auto.jellyfin-ffmpeg
  ];
}
