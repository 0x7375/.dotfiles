{
  myLib,
  pkgs,
  ...
}:

{
  services.qBittorrent = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.media.qbittorrent-nox;
    openFirewall = true;
  };
}
