{
  flake.lib.notifyOnServiceFailure = service: {
    ${service}.unitConfig.OnFailure = "service-failure-notify@%N.service";
  };

  flake.modules.nixos.pearlman =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      inherit (config.me) services;
      inherit (services.ntfy) url port;
    in
    {
      me.services.ntfy = {
        subdomain = "notify";
        port = 8719;
        webSockets = true;
      };

      services.ntfy-sh = {
        enable = true;
        settings = {
          base-url = "http://localhost:" + toString port;
          listen-http = ":" + toString port;
          auth-default-access = "read-write";
          cache-file = "/var/lib/ntfy-sh/cache.db";
        };
      };
      networking.firewall.allowedTCPPorts = [ port ];

      systemd.services."service-failure-notify@" = {
        description = "Send notification when a service fails";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.curl} -d \"Service %i failed\" ${url}/status";
        };
      };
    };
}
