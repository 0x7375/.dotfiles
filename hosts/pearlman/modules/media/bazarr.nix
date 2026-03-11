{ config, pkgs, ... }:

{
  services.bazarr = {
    enable = true;
    package = pkgs.auto.bazarr;
    openFirewall = true;
    group = config.me.mediaGroup;
  };
}
