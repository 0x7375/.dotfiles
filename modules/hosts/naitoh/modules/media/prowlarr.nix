{
  flake.modules.nixos.naitoh =
    { config, ... }:
    {
      me.services = {
        flaresolverr = {
          subdomain = "solver";
          inherit (config.services.flaresolverr) port;
        };
        prowlarr = {
          subdomain = "indexer";
          inherit (config.nixflix.radarr.config.hostConfig) port;
        };
      };

      me.hostSecrets."prowlarr/api_key" = { };
      me.hostSecrets."prowlarr/pw" = { };

      me.hostSecrets."indexers/c411" = { };
      me.hostSecrets."indexers/torr9" = { };
      me.hostSecrets."indexers/tr4ker" = { };

      networking.enableIPv6 = false;

      nixflix = {
        flaresolverr.enable = true;
        prowlarr = {

          enable = true;
          openFirewall = true;
          config = {
            apiKey._secret = config.sops.secrets."prowlarr/api_key".path;
            hostConfig.password._secret = config.sops.secrets."prowlarr/pw".path;
            indexers =
              let
                solver = [ "flaresolverr" ];
                withSolver = name: { inherit name solver; };
              in
              [
                { name = "World-torrent"; }
                { name = "Knaben"; }
                { name = "LimeTorrents"; }
                { name = "Nyaa.si"; }
                { name = "Tokyo Toshokan"; }
                { name = "YTS"; }
                (withSolver "1337x")
                (withSolver "Uindex")
                (withSolver "Torrent Downloads")
                (withSolver "Internet Archive")
                (withSolver "Torrent9")
                {
                  name = "C411";
                  apikey._secret = config.sops.secrets."indexers/c411".path;
                }
                {
                  name = "Torr9";
                  passkey._secret = config.sops.secrets."indexers/torr9".path;
                }
                {
                  name = "TR4KER";
                  apikey._secret = config.sops.secrets."indexers/tr4ker".path;
                }
              ];
          };
        };
      };
    };
}
