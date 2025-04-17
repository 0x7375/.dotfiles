{
  myLib,
  pkgs,
  ...
}:

{
  services.sonarr = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.auto.sonarr;
    openFirewall = true;
  };
}
