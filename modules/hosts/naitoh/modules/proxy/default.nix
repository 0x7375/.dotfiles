{ self, ... }:

{
  flake.modules.nixos.naitoh =
    {
      lib,
      secrets,
      config,
      ...
    }:
    let
      inherit (config.me) domain hostname;
      mkSubDomain =
        {
          port,
          path ? "",
          webSockets ? false,
          extraConfig ? "",
          ...
        }:
        {
          forceSSL = true;
          useACMEHost = domain;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString port}";
              proxyWebsockets = webSockets;
              inherit extraConfig;
            };
          }
          // lib.optionalAttrs (path != "") {
            "= /" = {
              return = "302 /${path}";
            };
          };
        };

      generatedHtml =
        let
          links = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: service: ''<li><a href="${service.url}">${name}</a></li>''
            ) config.me.services
          );
        in
        # html
        ''
          <!DOCTYPE html>
          <html>
            <head>
              <title>~/Homepage</title>
              <style type="text/css">
              ${builtins.readFile ./styles.css}
              </style>
            </head>
            <styles href="./styles.css"
            <body>
              <h1>~/Homepage</h1>
              <ul id="services">${links}</ul>
            </body>
          </html>
        '';
    in
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      systemd.tmpfiles.rules =
        let
          content = builtins.replaceStrings [ "\n" ] [ "\\n" ] generatedHtml;
        in
        [
          "f+ /var/www/index.html 0644 root root - ${content}"
        ];

      services.nginx = {
        enable = true;
        virtualHosts = {
          _ = {
            default = true;
            addSSL = true;
            useACMEHost = domain;
            extraConfig = "return 444;";
          };

          "${domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/".root = "/var/www";
          };

          "router.${domain}" = {
            forceSSL = true;
            useACMEHost = domain;
            locations."/".proxyPass = "http://${config.me.networkIps.lan.gateway}";
          };
        }
        // lib.mapAttrs' (
          _: service: lib.nameValuePair "${service.subdomain}.${domain}" (mkSubDomain service)
        ) config.me.services;
      };

      systemd.services =
        self.lib.notifyOnServiceFailure "nginx" // self.lib.notifyOnServiceFailure "acme-${domain}";

      me.hostSecrets.cloudflare_dns_token = { };
      sops.templates."cloudflare.env".content =
        # bash
        ''
          CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_dns_token}
        '';

      persist.directories = [ "/var/lib/acme" ];

      security.acme = {
        acceptTerms = true;
        defaults.email = "acme.ranked@0xaa.me";
        certs."${domain}" = {
          extraDomainNames = [ "*.${domain}" ];
          dnsProvider = "cloudflare";
          environmentFile = config.sops.templates."cloudflare.env".path;
          webroot = null;
        };
      };
    };
}
