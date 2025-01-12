{
  lib,
  config,
  pkgs,
  secrets,
  ...
}:

lib.mkIf (config.me.secrets.enable && config.me.network.enable) {
  age.secrets.networking = {
    file = "${secrets}/networking.age";
    owner = config.me.user;
  };

  age.secrets.nextdnsId = {
    file = "${secrets}/nextdnsId.age";
  };

  system.activationScripts."resolved-secret-substitution" = ''
    secret=$(cat "${config.age.secrets.nextdnsId.path}")
    configFile=/etc/systemd/resolved.conf
    ${pkgs.gnused}/bin/sed -i "s#@nextdnsId@#$secret#" "$configFile"
  '';

  services.resolved = {
    enable = true;
    extraConfig = ''
      [Resolve]
      DNS=45.90.28.0#@nextdnsId@.dns.nextdns.io
      DNS=2a07:a8c0::#@nextdnsId@.dns.nextdns.io
      DNS=45.90.30.0#@nextdnsId@.dns.nextdns.io
      DNS=2a07:a8c1::#@nextdnsId@.dns.nextdns.io
      DNSOverTLS=yes
    '';
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.age.secrets.networking.path ];
  };
}
