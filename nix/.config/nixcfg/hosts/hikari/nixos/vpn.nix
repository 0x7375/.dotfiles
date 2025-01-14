{
  lib,
  secrets,
  pkgs,
  config,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets."hikari/protonvpn_pk" = { };

  services.protonvpn = {
    enable = true;

    interface = {
      privateKeyFile = config.sops.secrets."hikari/protonvpn_pk".path;
    };

    endpoint = {
      publicKey = "wYsaKyJteQ1gYoJZAZT0FettXDOidPhQZwl0DhaabF0=";
      ip = "redacted";
    };
  };

  # networking.firewall.allowedUDPPorts = [ 51821 ];

  # environment.systemPackages = with pkgs; [
  #   wireguard-tools
  # ];

  # age.secrets.server-vpn-pk = {
  #   file = "${secrets}/server-vpn-pk.age";
  #   owner = config.me.user;
  # };

  # networking.nat.enable = true;
  # networking.nat.externalInterface = "end0";
  # networking.nat.internalInterfaces = [ "homevpn" ];

  # networking.wg-quick.interfaces.homevpn =
  #   let
  #     interface = "homevpn";
  #   in
  #   {
  #     address = [ "10.0.0.1/24" ];
  #     listenPort = 51821;
  #     privateKeyFile = config.age.secrets.server-vpn-pk.path;
  #
  #     postUp = ''
  #       ${pkgs.iptables}/bin/iptables -A FORWARD -i ${interface} -j ACCEPT
  #       ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o end0 -j MASQUERADE
  #     '';
  #
  #     preDown = ''
  #       ${pkgs.iptables}/bin/iptables -D FORWARD -i ${interface} -j ACCEPT
  #       ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o end0 -j MASQUERADE
  #     '';
  #
  #     peers = [
  #       # laptop
  #       {
  #         publicKey = "apB8TVyEJ7G/gLe5b3ckvUYJSSKv85rl1jWkZoiEQgE=";
  #         presharedKeyFile = config.age.secrets.laptop-vpn-psk.path;
  #         allowedIPs = [ "10.0.0.2/32" ];
  #       }
  #     ];
  #   };
}
