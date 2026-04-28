{ self, ... }:

{
  flake.shared.vpnPeer =
    {
      config,
      ...
    }:
    let
      inherit (config.me) hostname host;
    in
    {
      sops.secrets.server_vpn_endpoint.owner = config.me.user;
      me.hostSecrets."vpn/pk" = {
        owner = config.me.user;
      };
      sops.secrets."${hostname}/vpn/psk".owner = config.me.user;

      sops.templates."home-vpn-${hostname}.conf".content =
        let
          inherit (config.me) networkIps hosts server;
        in
        ''
          [Interface]
          Address = ${host.ips.vpn}/24
          PrivateKey = ${config.sops.placeholder."vpn/pk"}

          [Peer]
          PublicKey = PpCxUOTz7Heh3B29OnI3XNZAKJ8abUETMzFNj3gpTyo=
          PresharedKey = ${config.sops.placeholder."${hostname}/vpn/psk"}
          AllowedIPs = ${networkIps.vpn.subnet},${networkIps.lan.subnet},${hosts.${server}.ips.lan}/32
          Endpoint = ${config.sops.placeholder.server_vpn_endpoint}:1637
        '';

    };

  flake.darwin.vpnPeer =
    { config, pkgs, ... }:
    let
      inherit (config.me) hostname;
    in
    {
      imports = [ self.shared.vpnPeer ];

      packages = [ pkgs.wireguard-tools ];
      sops.templates."home-vpn-${hostname}.conf".path = "/etc/wireguard/home.conf";
    };

  flake.nixos.vpnPeer =
    { config, pkgs, ... }:
    let
      inherit (config.me) hostname;
    in
    {
      imports = [ self.shared.vpnPeer ];

      networking.wg-quick.interfaces.home = {
        autostart = false;
        configFile = config.sops.templates."home-vpn-${hostname}.conf".path;
      };

      sops.secrets.home_ssid.owner = config.me.user;

      networking.networkmanager.dispatcherScripts = [
        {
          source = pkgs.writeShellScript "vpn-home-manager" ''
            home_ssid=$(cat "${config.sops.secrets.home_ssid.path}")
            [[ "$2" = "dhcp4-change" ]] || exit 0
            if [[ "$CONNECTION_ID" == "$home_ssid" ]]; then
              systemctl stop wg-quick-home.service
            else
              systemctl start wg-quick-home.service
            fi
          '';
          type = "basic";
        }
      ];
    };
}
