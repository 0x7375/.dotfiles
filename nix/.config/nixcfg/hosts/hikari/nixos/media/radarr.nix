{
  myLib,
  pkgs,
  ...
}:

{
  services.radarr = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.media.radarr;
    openFirewall = true;
  };
}
