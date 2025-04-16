{ pkgs, ... }:

{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    package = pkgs.auto.jellyseerr;
    configDir = "/var/lib/jellyseerr";
  };
}
