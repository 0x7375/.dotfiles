{
  lib,
  config,
  pkgs,
  secrets,
  ...
}:

let
  template = "@nextdnsId@";
in
lib.mkIf (config.me.secrets.enable && config.me.network.enable) {
  sops.secrets.networkingEnvironment = {
    sopsFile = "${secrets}/networking-environment.env";
    format = "dotenv";
    key = "";
    owner = config.me.user;
  };

  sops.secrets.nextdns_id = {
    owner = config.me.user;
  };

  system.activationScripts."resolved-secret-substitution" = ''
    secret=$(cat "${config.sops.secrets.nextdns_id.path}")
    configFile=/etc/systemd/resolved.conf
    ${pkgs.gnused}/bin/sed -i "s#${template}#$secret#" "$configFile"
  '';

  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS=45.90.28.0#${template}.dns.nextdns.io
      DNS=2a07:a8c0::#${template}.dns.nextdns.io
      DNS=45.90.30.0#${template}.dns.nextdns.io
      DNS=2a07:a8c1::#${template}.dns.nextdns.io
      DNSOverTLS=yes
    '';
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
