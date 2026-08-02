{ self, ... }:

{
  flake.modules.nixos.naitoh =
    {
      config,
      ...
    }:
    let
      inherit (config.me.services.radicale) port;
    in
    {
      me.hostSecrets.radicale_users.owner = "radicale";

      systemd.services.radicale = self.lib.afterSopsService;

      services.radicale = {
        enable = true;
        settings = {
          server.hosts = [ "0.0.0.0:${toString port}" ];
          auth = {
            type = "htpasswd";
            htpasswd_filename = config.sops.secrets.radicale_users.path;
            htpasswd_encryption = "bcrypt";
          };
        };
      };
    };
}
