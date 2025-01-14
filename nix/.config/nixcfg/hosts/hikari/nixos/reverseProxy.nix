{
  secrets,
  lib,
  config,
  ...
}:

let
  mkSubDomain = port: {
    forceSSL = true;
    useACMEHost = url;
    locations."/".proxyPass = "http://${url}:${port}";
  };
  url = "shimu.duckdns.org";
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "${url}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/var/www";
        proxyPass = "http://${url}:7575";
      };
    };

    "jellyfin.${url}" = mkSubDomain "8096";
    "request.${url}" = mkSubDomain "5055";
    "sync.${url}" = mkSubDomain "8384";
    "torrent.${url}" = mkSubDomain "8080";
    "prowlarr.${url}" = mkSubDomain "9696";
    "radarr.${url}" = mkSubDomain "7878";
    "sonarr.${url}" = mkSubDomain "8989";

    "router.${url}" = {
      forceSSL = true;
      useACMEHost = "${url}";
      locations."/".proxyPass = "http://192.168.1.254";
    };
  };

  sops.secrets."hikari/duckdns_token" = { };

  security.acme = lib.mkIf config.me.secrets.enable {
    acceptTerms = true;
    defaults.email = "nginx.commerce973@simplelogin.com";
    certs."${url}" = {
      extraDomainNames = [ "*.${url}" ];
      dnsProvider = "duckdns";
      environmentFile = config.sops.secrets."hikari/duckdns_token".path;
      webroot = null;
    };
  };
}
