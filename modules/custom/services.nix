{
  config,
  lib,
  ...
}:

let
  parentConfig = config;
  inherit (lib) mkEnableOption mkOption types;

  serviceSubmodule =
    { config, ... }:
    {
      options = {
        subdomain = mkOption {
          type = types.str;
          description = "Network subdomain";
        };

        port = mkOption {
          type = types.int;
          description = "Network port";
        };

        url = mkOption {
          type = types.str;
          internal = true;
          default = "https://${config.subdomain}.${parentConfig.me.domain}";
          description = "Constructed public URL for this service";
        };

        webSockets = mkEnableOption "Enable websocket proxying";

        extraConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Extra configuration passed to nginx";
        };
      };
    };
in
{
  options.me = {
    domain = mkOption {
      type = types.str;
      default = "0xaa.me";
      description = "My domain name";
    };

    services = mkOption {
      description = "Central server services definition";
      internal = true;
      type = types.attrsOf (types.submodule serviceSubmodule);
      default = {
        attic = {
          subdomain = "cache";
          port = 8082;
          extraConfig = ''
            client_max_body_size 0;
          '';
        };
        homarr = {
          subdomain = "home";
          port = 7575;
          webSockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-Host $host;
          '';
        };
        dashdot = {
          subdomain = "dash";
          port = 3001;
        };
        bazarr = {
          subdomain = "subtitles";
          port = 6767;
        };
        cleanuparr = {
          subdomain = "cleanup";
          port = 11011;
          webSockets = true;
        };
        filebrowser = {
          subdomain = "file";
          port = 8081;
        };
        jellyfin = {
          subdomain = "media";
          port = 8096;
        };
        seerr = {
          subdomain = "request";
          port = 5055;
        };
        ntfy = {
          subdomain = "notify";
          port = 8719;
          webSockets = true;
        };
        prowlarr = {
          subdomain = "indexer";
          port = 9696;
        };
        radarr = {
          subdomain = "movies";
          port = 7878;
        };
        sonarr = {
          subdomain = "shows";
          port = 8989;
        };
        qBittorrent = {
          subdomain = "torrent";
          port = 8080;
        };
        syncthing = {
          subdomain = "sync";
          port = 8384;
        };
      };
    };
  };
}
