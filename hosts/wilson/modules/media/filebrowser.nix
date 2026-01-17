{ pkgs, ... }:

{
  services.filebrowser = {
    enable = true;
    package = pkgs.auto.filebrowser;
    openFirewall = true;
    group = "media";
    settings = {
      port = 8081;
      address = "0.0.0.0";
      root = "/data/";
    };
  };
}
