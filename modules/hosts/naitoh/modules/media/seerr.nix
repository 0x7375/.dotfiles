{ self, ... }:

{
  flake.modules.nixos.naitoh =
    {
      config,
      ...
    }:
    let
      inherit (self.lib) afterSopsService;
    in
    {
      me.services.seerr = {
        subdomain = "request";
        port = config.nixflix.seerr.port;
      };

      me.hostSecrets."seerr/api_key" = { };

      systemd.services.seerr-env = afterSopsService;
      systemd.services.seerr-setup = afterSopsService;
      systemd.services.seerr-user-settings = afterSopsService;

      systemd.services.seerr-jellyfin = {
        after = [ "jellyfin.service" ];
        requires = [ "jellyfin.service" ];
      };

      nixflix.seerr = {
        enable = true;
        openFirewall = true;
        apiKey._secret = config.sops.secrets."seerr/api_key".path;
      };
    };
}
