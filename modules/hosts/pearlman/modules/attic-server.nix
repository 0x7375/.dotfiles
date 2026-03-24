{
  flake.nixos.pearlman =
    {
      secrets,
      config,
      ...
    }:
    let
      inherit (config.me.services.attic) port url;
      inherit (config.me) hostname;
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          attic-server = (
            (prev.crossPkgs or prev).attic-server.overrideAttrs (old: {
              env = (old.env or { }) // {
                RUSTFLAGS = "-C target-feature=-aes,-sha2,-crypto";
              };
            })
          );
        })
      ];

      networking.firewall.allowedTCPPorts = [ port ];

      sops.secrets.attic = {
        sopsFile = "${secrets}/${hostname}/attic.env";
        format = "dotenv";
        key = "";
      };

      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.attic.path;
        settings = {
          listen = "[::]:${toString port}";
          api-endpoint = url + "/";
          jwt = { };

          chunking = {
            nar-size-threshold = 64 * 1024;
            min-size = 16 * 1024;
            avg-size = 256 * 1024;
            max-size = 256 * 1024;
          };

          garbage-collection = {
            default-retention-period = "6 months";
          };
        };
      };
    };
}
