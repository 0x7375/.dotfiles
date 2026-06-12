let
  serverPublicKey = "PpCxUOTz7Heh3B29OnI3XNZAKJ8abUETMzFNj3gpTyo=";
in
{
  flake.modules.generic.vpnPeer =
    { config, ... }:
    let
      inherit (config.me) hostname user;
    in
    {
      sops.secrets.server_vpn_endpoint.owner = user;
      me.hostSecrets."vpn/pk".owner = user;
      sops.secrets."${hostname}/vpn/psk".owner = user;

      sops.templates."home-vpn-${hostname}.env".content = ''
        WG_PRIVATE_KEY=${config.sops.placeholder."vpn/pk"}
        WG_PSK=${config.sops.placeholder."${hostname}/vpn/psk"}
        WG_ENDPOINT=${config.sops.placeholder.server_vpn_endpoint}
      '';
    };

  flake.modules.darwin.vpnPeer =
    { config, pkgs, ... }:
    let
      inherit (config.me)
        hostname
        host
        networkIps
        hosts
        server
        ;
    in
    {
      packages = [ pkgs.wireguard-tools ];

      sops.templates."home-vpn-${hostname}.conf" = {
        path = "/etc/wireguard/home.conf";
        content = ''
          [Interface]
          Address = ${host.ips.vpn}/24
          PrivateKey = ${config.sops.placeholder."vpn/pk"}
          [Peer]
          PublicKey = ${serverPublicKey}
          PresharedKey = ${config.sops.placeholder."${hostname}/vpn/psk"}
          AllowedIPs = ${networkIps.vpn.subnet},${networkIps.lan.subnet},${hosts.${server}.ips.lan}/32
          Endpoint = ${config.sops.placeholder.server_vpn_endpoint}:1637
        '';
      };
    };

  flake.modules.nixos.vpnPeer =
    { config, pkgs, ... }:
    let
      inherit (config.me)
        hostname
        host
        networkIps
        hosts
        server
        ;
    in
    {
      networking.networkmanager.ensureProfiles = {
        environmentFiles = [
          config.sops.templates."home-vpn-${hostname}.env".path
        ];
        profiles."home-vpn" = {
          connection = {
            id = "home-vpn";
            type = "wireguard";
            interface-name = "wg0";
            autoconnect = false;
          };
          wireguard.private-key = "$WG_PRIVATE_KEY";
          "wireguard-peer.${serverPublicKey}" = {
            endpoint = "$WG_ENDPOINT:1637";
            allowed-ips = "${networkIps.vpn.subnet};${networkIps.lan.subnet};${hosts.${server}.ips.lan}/32";
            preshared-key = "$WG_PSK";
          };
          ipv4 = {
            address1 = "${host.ips.vpn}/24";
            method = "manual";
          };
          ipv6.method = "disabled";
        };
      };

      sops.secrets.home_ssid.owner = config.me.user;

      networking.networkmanager.dispatcherScripts = [
        {
          source = pkgs.writeShellScript "vpn-home-manager" ''
            [[ "$2" == "up" || "$2" == "down" || "$2" == "dhcp4-change" ]] || exit 0

            home_ssid=$(cat "${config.sops.secrets.home_ssid.path}")

            if nmcli -g NAME connection show --active | grep -qx "$home_ssid"; then
              nmcli connection down home-vpn 2>/dev/null || true
            else
              nmcli connection up home-vpn 2>/dev/null || true
            fi
          '';
          type = "basic";
        }
      ];
    };
}
