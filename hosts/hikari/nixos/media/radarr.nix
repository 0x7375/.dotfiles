{
  myLib,
  pkgs,
  ...
}:

{
  services.radarr = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.auto.radarr;
    openFirewall = true;
  };
}
