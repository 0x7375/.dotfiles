{
  myLib,
  pkgs,
  ...
}:

{
  services.sonarr = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.media.sonarr;
    openFirewall = true;
  };
}
