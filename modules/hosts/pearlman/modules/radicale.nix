{
  flake.modules.nixos.pearlman =
    {
      config,
      ...
    }:
    let
      inherit (config.me.services.radicale) port;
    in
    {
      me.hostSecrets.radicale_users.owner = "radicale";

      services.radicale = {
        enable = true;
        settings = {
          server.hosts = [ "0.0.0.0:${port}" ];
          auth = {
            type = "htpasswd";
            htpasswd_filename = config.sops.secrets.radicale_users.path;
            htpasswd_encryption = "bcrypt";
          };
        };
      };
    };
}
