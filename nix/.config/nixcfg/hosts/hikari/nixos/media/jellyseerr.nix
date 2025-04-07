{ pkgs, ... }:

{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    package = pkgs.media.jellyseerr;
    configDir = "/var/lib/jellyseerr";
  };
}
