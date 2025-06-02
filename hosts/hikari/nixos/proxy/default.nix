{
  lib,
  secrets,
  myLib,
  config,
  ...
}:

let
  url = "0xaa.me";
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

      "media.${url}" = mkSubDomain 8096;
      "request.${url}" = mkSubDomain 5055;
      "sync.${url}" = mkSubDomain 8384;
      "torrent.${url}" = mkSubDomain 8080;
      "indexer.${url}" = mkSubDomain 9696;
      "movies.${url}" = mkSubDomain 7878;
      "series.${url}" = mkSubDomain 8989;
      "subtitles.${url}" = mkSubDomain 6767;

      "router.${url}" = {
        forceSSL = true;
        useACMEHost = "${url}";
        locations."/".proxyPass = "http://${myLib.network.lan.gateway}";
      };
    };
  };

  systemd.services =
    myLib.notifyOnServiceFailure "nginx"
    // myLib.notifyOnServiceFailure "acme-${url}";

  sops.secrets.cloudflare = {
    sopsFile = "${secrets}/cloudflare.env";
    format = "dotenv";
    key = "";
  };

  security.acme = lib.mkIf config.me.secrets.enable {
    acceptTerms = true;
    defaults.email = "nginx.commerce973@simplelogin.com";
    certs."${url}" = {
      extraDomainNames = [ "*.${url}" ];
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.cloudflare.path;
      webroot = null;
    };
  };
}
