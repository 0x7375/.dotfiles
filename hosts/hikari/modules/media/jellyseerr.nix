{ pkgs, ... }:

{
  services.jellyseerr = {
    enable = false;
    openFirewall = true;
    package = pkgs.auto.jellyseerr;
    configDir = "/var/lib/jellyseerr";
  };
}
