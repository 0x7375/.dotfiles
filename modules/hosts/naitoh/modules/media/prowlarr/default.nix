{
  flake.modules.nixos.naitoh =
    { pkgs, config, ... }:
    {
      me.services = {
        flaresolverr = {
          subdomain = "solver";
          inherit (config.services.flaresolverr) port;
        };
        prowlarr = {
          subdomain = "indexer";
          inherit (config.nixflix.prowlarr.config.hostConfig) port;
        };
      };

      me.hostSecrets."prowlarr/api_key" = { };
      me.hostSecrets."prowlarr/pw" = { };

      me.hostSecrets."indexers/c411" = { };
      me.hostSecrets."indexers/tr4ker" = { };

      networking.enableIPv6 = false;

      systemd.services.prowlarr.preStart = ''
        DATA_DIR="${config.nixflix.prowlarr.dataDir}" 

        mkdir -p "$DATA_DIR/Definitions/Custom"
        cp ${./c411.yml} "$DATA_DIR/Definitions/Custom/c411-custom.yml"
        chmod 644 "$DATA_DIR/Definitions/Custom/c411-custom.yml"
      '';

      services.flaresolverr.package = pkgs.auto.flaresolverr;

      nixflix = {
        flaresolverr.enable = true;
        prowlarr = {
          enable = true;
          package = pkgs.auto.prowlarr;
          openFirewall = true;
          config = {
            apiKey._secret = config.sops.secrets."prowlarr/api_key".path;
            hostConfig.password._secret = config.sops.secrets."prowlarr/pw".path;
            indexers =
              let
                tags = [ "flaresolverr" ];
                withSolver = name: { inherit name tags; };
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
                  name = "C411 (Custom)";
                  apikey._secret = config.sops.secrets."indexers/c411".path;
                  priority = 10;
                  multilang = true;
                  multilanguage = 5;
                }
                {
                  name = "TR4KER";
                  apikey._secret = config.sops.secrets."indexers/tr4ker".path;
                  priority = 10;
                  multilang = true;
                  multilanguage = 5;
                }
              ];
          };
        };
      };
    };
}
