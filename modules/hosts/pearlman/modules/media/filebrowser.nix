{
  flake.modules.nixos.pearlman =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      me.services.filebrowser = {
        subdomain = "file";
        port = 8081;
      };

      services.filebrowser = {
        enable = true;
        package = pkgs.auto.filebrowser;
        openFirewall = true;
        group = "media";
        settings = {
          inherit (config.me.services.filebrowser) port;
          address = "0.0.0.0";
          root = "/data/";
        };
      };

      systemd.tmpfiles.settings.filebrowser."/data/".d = {
        mode = lib.mkForce "0775";
        user = lib.mkForce "root";
      };
      systemd.services.filebrowser.serviceConfig.UMask = lib.mkForce "0007";
    };
}
