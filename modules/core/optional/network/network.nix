{
  lib,
  config,
  mkBundle,
  ...
}:

lib.mkIf config.me.network.enable (mkBundle {
  darwin.preActivation = "rm -f /etc/hosts";

  environment.etc.hosts.text =
    let
      validHosts = lib.filterAttrs (_: v: v.ips.lan != null) config.me.hosts;
      ipHostPair = lib.mapAttrsToList (h: v: "${v.ips.lan} ${h} ${h}.local") validHosts;
    in
    lib.mkForce ''
      127.0.0.1 localhost
      255.255.255.255 broadcasthost
      ::1 localhost
      ${builtins.concatStringsSep "\n" ipHostPair}
    '';

  nixos = {
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

    services.resolved.settings.Resolve.FallbackDNS = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
    ];

    users.users.${config.me.user}.extraGroups = [ "networkmanager" ];

    # don't wait for network on boot
    systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
    networking.firewall.enable = true;
  };
})
