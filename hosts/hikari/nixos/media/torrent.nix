{
  myLib,
  pkgs,
  ...
}:

{
  services.qBittorrent = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.auto.qbittorrent-nox;
    openFirewall = true;
  };
}
