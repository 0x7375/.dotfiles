{
  lib,
  secrets,
  config,
  ...
}:

let
  inherit (config.me) hosts hostname;
  url = "0xaa.me";
  ip = hosts.${hostname}.ips.lan;
  mkSubDomain =
    {
      port,
      webSockets ? false,
    }:
    {
      forceSSL = true;
      useACMEHost = url;
      locations."/" = {
        proxyPass = "http://${ip}:${toString port}";
        proxyWebsockets = webSockets;
      };
    };
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  systemd.tmpfiles.rules =
    let
      content = builtins.replaceStrings [ "\n" ] [ "\\n" ] (builtins.readFile ./index.html);
    in
    [
      "f+ /var/www/index.html 0644 root root - ${content}"
    ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "${url}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
          index = "index.html";
        };
      };

      "shop.${url}" = mkSubDomain { port = 3000; };
      "media.${url}" = mkSubDomain { port = 8096; };
      "request.${url}" = mkSubDomain { port = 5055; };
      "sync.${url}" = mkSubDomain { port = 8384; };
      "torrent.${url}" = mkSubDomain { port = 8080; };
      "file.${url}" = mkSubDomain { port = 8081; };
      "indexer.${url}" = mkSubDomain { port = 9696; };
      "movies.${url}" = mkSubDomain { port = 7878; };
      "shows.${url}" = mkSubDomain { port = 8989; };
      "subtitles.${url}" = mkSubDomain { port = 6767; };
      "notify.${url}" = mkSubDomain {
        port = 8719;
        webSockets = true;
      };
      "cleanup.${url}" = mkSubDomain {
        port = 11011;
        webSockets = true;
      };

      "router.${url}" = {
        forceSSL = true;
        useACMEHost = url;
        locations."/".proxyPass = "http://${config.me.networkIps.lan.gateway}";
      };
    };
  };

  systemd.services =
    lib.my.notifyOnServiceFailure "nginx" // lib.my.notifyOnServiceFailure "acme-${url}";

  sops.secrets.cloudflare = {
    sopsFile = "${secrets}/cloudflare.env";
    format = "dotenv";
    key = "";
  };

  security.acme = lib.mkIf config.me.secrets.enable {
    acceptTerms = true;
    defaults.email = "acme.ranked@0xaa.me";
    certs."${url}" = {
      extraDomainNames = [ "*.${url}" ];
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.cloudflare.path;
      webroot = null;
    };
  };
}
