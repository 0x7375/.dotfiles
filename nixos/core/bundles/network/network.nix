{
  myLib,
  lib,
  config,
  ...
}:

lib.mkIf config.me.network.enable {
  networking.extraHosts =
    let
      inherit (myLib) network;
    in
    ''
      ${network.lan.addr.laptop} ryusei ryusei.local
      ${network.lan.addr.desktop} yugen yugen.local
      ${network.lan.addr.server} hikari hikari.local
    '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    connectionConfig = {
      "ipv4.ignore-auto-dns" = true;
      "ipv6.ignore-auto-dns" = true;
    };
  };

  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = false;
      };
    };
  };

  services.resolved.fallbackDns = [
    "9.9.9.9#dns.quad9.net"
    "149.112.112.112#dns.quad9.net"
    "2620:fe::fe#dns.quad9.net"
    "2620:fe::9#dns.quad9.net"
  ];

  users.users.${config.me.user}.extraGroups = [ "networkmanager" ];

  networking.firewall.enable = true;
}
