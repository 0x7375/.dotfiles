{ self, ... }:

{
  flake.modules.nixos.naitoh =
    {
      config,
      pkgs,
      ...
    }:
    {
      me.services.seerr = {
        subdomain = "request";
        port = config.nixflix.seerr.port;
      };

      me.hostSecrets."seerr/api_key" = { };

      systemd.services.seerr-jellyfin = {
        after = [ "jellyfin.service" ];
        requires = [ "jellyfin.service" ];
      };

      nixflix.seerr = {
        enable = true;
        package = pkgs.auto.seerr;
        openFirewall = true;
        apiKey._secret = config.sops.secrets."seerr/api_key".path;
      };
    };
}
