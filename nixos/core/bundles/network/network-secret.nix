{
  lib,
  config,
  secrets,
  pkgs,
  ...
}:

let
  template = "@nextdnsId@";
in
lib.mkIf (config.me.secrets.enable && config.me.network.enable) {
  sops.secrets.nextdns_id = {
    owner = config.me.user;
    neededForUsers = true;
  };

  system.activationScripts."unbound-secret-substitution" = ''
    secret=$(cat "${config.sops.secrets.nextdns_id.path}")
    configFile=/etc/unbound/unbound.conf
    ${lib.getExe' pkgs.gnused "sed"} -i "s#${template}#$secret#" "$configFile"
  '';

  services.unbound = {
    enable = true;
    settings.forward-zone = [
      {
        name = ".";
        forward-tls-upstream = "yes";
        forward-addr = [
          "45.90.28.0@853#${template}.dns.nextdns.io"
          "2a07:a8c0::@853#${template}.dns.nextdns.io"
          "45.90.30.0@853#${template}.dns.nextdns.io"
          "2a07:a8c1::@853#${template}.dns.nextdns.io"
        ];
      }
    ];
  };

  sops.secrets.networkingEnvironment = {
    sopsFile = "${secrets}/networking-environment.env";
    format = "dotenv";
    key = "";
    owner = config.me.user;
  };

  networking.networkmanager.ensureProfiles = lib.mkIf (config.me.hostname != "hikari") {
    environmentFiles = [ config.sops.secrets.networkingEnvironment.path ];
    profiles = {
      Home = {
        connection = {
          id = "home";
          type = "wifi";
        };
        wifi = {
          ssid = "$SSID_HOME";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PSK_HOME";
        };
      };
      Sekai = {
        connection = {
          id = "sekai";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "sekai";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PSK_SEKAI";
        };
      };
    };
  };
}
