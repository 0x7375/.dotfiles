{ lib, pkgs, ... }:

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

  systemd.tmpfiles.settings.filebrowser."/data/".d.mode = lib.mkForce "0770";
  systemd.services.filebrowser.serviceConfig.UMask = lib.mkForce "0007";
}
