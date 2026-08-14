{
  flake.modules.nixos.naitoh =
    { config, pkgs, ... }:
    {
      me.services.bazarr = {
        subdomain = "subtitles";
        port = config.services.bazarr.listenPort;
      };

      services.bazarr = {
        enable = true;
        package = pkgs.auto.bazarr;
        openFirewall = true;
        group = config.me.mediaGroup;
        dataDir = "/data/main/.state/bazarr";
      };

      systemd.services.bazarr.serviceConfig.UMask = "0002";
    };
}
