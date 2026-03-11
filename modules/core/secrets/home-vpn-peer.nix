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
  mkHostSecret = lib.my.mkHostSecret hostname;
in
{
  options.me.vpnPeer.enable = lib.mkEnableOption "Setup wireguard vpn peer";

  config = lib.mkIf (cfg.secrets.enable && cfg.vpnPeer.enable) (mkBundle {
    sops.secrets.server_vpn_endpoint.owner = config.me.user;
    sops.secrets."vpn/pk" = mkHostSecret "vpn/pk" { owner = config.me.user; };
    sops.secrets."${hostname}/vpn/psk".owner = config.me.user;

    sops.templates."home-vpn-${hostname}.conf".content =
      let
        inherit (config.me) networkIps;
      in
      ''
        [Interface]
        Address = ${host.ips.vpn}/24
        PrivateKey = ${config.sops.placeholder."vpn/pk"}

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

    nixos = {
      networking.wg-quick.interfaces.home = {
        autostart = false;
        configFile = config.sops.templates."home-vpn-${hostname}.conf".path;
      };

      systemd.services.vpn-home-manager = {
        description = "Auto-toggle home VPN based on network location";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.iproute2 ];

        script =
          # bash
          ''
            is_home() {
              ip route show "${config.me.networkIps.lan.subnet}" | grep -q "proto kernel"
            }

            check_and_toggle() {
              if is_home; then
                systemctl stop wg-quick-home.service || true
              else
                systemctl start wg-quick-home.service || true
              fi
            }

            check_and_toggle
            ip monitor route | while read -r _; do
              check_and_toggle
            done
          '';

        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = "5s";
        };
      };
    };
  });
}
