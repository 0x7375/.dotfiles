{
  lib,
  pkgs,
  config,
  mkBundle,
  ...
}:

let
  inherit (config.me) hostname host;
  cfg = config.me;
in
{
  options.me.vpnPeer.enable = lib.mkEnableOption "Setup wireguard vpn peer";

  config = lib.mkIf (cfg.secrets.enable && cfg.vpnPeer.enable) (mkBundle {
    sops.secrets.server_vpn_endpoint.owner = config.me.user;
    sops.secrets."${hostname}/vpn/pk".owner = config.me.user;
    sops.secrets."${hostname}/vpn/psk".owner = config.me.user;

    sops.templates."home-vpn-${hostname}.conf".content =
      let
        inherit (config.me) networkIps;
      in
      ''
        [Interface]
        Address = ${host.ips.vpn}/24
        PrivateKey = ${config.sops.placeholder."${hostname}/vpn/pk"}

        [Peer]
        PublicKey = PpCxUOTz7Heh3B29OnI3XNZAKJ8abUETMzFNj3gpTyo=
        PresharedKey = ${config.sops.placeholder."${hostname}/vpn/psk"}
        AllowedIPs = ${networkIps.vpn.subnet},${networkIps.lan.subnet}
        Endpoint = ${config.sops.placeholder.server_vpn_endpoint}
      '';

    darwin = {
      packages = [ pkgs.wireguard-tools ];
      sops.templates."home-vpn-${hostname}.conf".path = "/etc/wireguard/home.conf";
    };

    nixos.networking.wg-quick.interfaces.home = {
      autostart = false;
      configFile = config.sops.templates."home-vpn-${hostname}.conf".path;
    };
  });
}
