{ config, pkgs, ... }:

{
  me.services.bazarr = {
    subdomain = "subtitles";
    port = 6767;
  };

  services.bazarr = {
    enable = true;
    package = pkgs.auto.bazarr;
    openFirewall = true;
    group = config.me.mediaGroup;
  };
}
