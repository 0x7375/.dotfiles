{
  lib,
  myLib,
  config,
  ...
}:

let
  url = "shimu.duckdns.org";
  ip = myLib.network.lan.addr.server;
  mkSubDomain = port: {
    forceSSL = true;
    useACMEHost = url;
    locations."/".proxyPass = "http://${ip}:${toString port}";
  };
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "${url}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
          proxyPass = "http://${ip}:7575";
        };
      };

      "media.${url}" = mkSubDomain 8096;
      "request.${url}" = mkSubDomain 5055;
      "sync.${url}" = mkSubDomain 8384;
      "torrent.${url}" = mkSubDomain 8080;
      "indexer.${url}" = mkSubDomain 9696;
      "movies.${url}" = mkSubDomain 7878;
      "series.${url}" = mkSubDomain 8989;

      "router.${url}" = {
        forceSSL = true;
        useACMEHost = "${url}";
        locations."/".proxyPass = "http://${myLib.network.lan.gateway}";
      };
    };
  };

  systemd.services = myLib.notifyOnServiceFailure "nginx";

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
