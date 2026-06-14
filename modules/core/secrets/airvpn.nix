let
  dns = {
    v4 = "10.128.0.1";
    v6 = "fd7d:76ee:e68f:a993::1";
  };

  ip = {
    v4 = "10.159.130.32";
    v6 = "fd7d:76ee:e68f:a993:e922:4b96:c567:bca5";
  };

  endpoint = "europe.vpn.airdns.org:1637";
in
{
  flake.modules.nixos.secrets =
    { config, ... }:
    {
      sops.secrets."airvpn/pk" = { };
      sops.secrets."airvpn/sk" = { };
      sops.secrets."airvpn/psk" = { };

      sops.templates."airvpn.nmconnection" = {
        path = "/etc/NetworkManager/system-connections/airvpn.nmconnection";
        mode = "0600";
        content =
          # ini
          ''
            [connection]
            id=airvpn
            type=wireguard
            interface-name=airvpn
            autoconnect=false

            [wireguard]
            private-key=${config.sops.placeholder."airvpn/sk"}
            mtu=1320

            [wireguard-peer.${config.sops.placeholder."airvpn/pk"}]
            endpoint=${endpoint}
            preshared-key=${config.sops.placeholder."airvpn/psk"}
            preshared-key-flags=0
            allowed-ips=0.0.0.0/0;::/0;
            persistent-keepalive=15

            [ipv4]
            address=${ip.v4}/32
            dns=${dns.v4};
            method=manual

            [ipv6]
            address=${ip.v6}/128
            dns=${dns.v6};
            method=manual
          '';
      };

      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };

  flake.modules.nixos.pearlman =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      networking.firewall.interfaces.airvpn =
        let
          inherit (config.me) vpnPort;
        in
        {
          allowedTCPPorts = [ vpnPort ];
          allowedUDPPorts = [ vpnPort ];
        };

      networking.networkmanager.unmanaged = [ "airvpn" ];

      sops.templates."airvpn.conf".content =
        let
          writeScriptFile = name: text: ((pkgs.writeShellScriptBin name text) + "/bin/${name}");
          table = "200";

          postUpFile =
            writeScriptFile "postUp.sh"
              # bash
              ''
                ip route add ${dns.v4} dev airvpn
                ip rule add from ${ip.v4} table ${table}

                ip -6 rule add from ${ip.v6} table ${table}
                ip rule add oif %i table ${table}
                ip -6 rule add oif %i table ${table}
              '';
          preDownFile =
            writeScriptFile "preDown.sh"
              # bash
              ''
                ip route del ${dns.v4} dev airvpn
                ip rule del from ${ip.v4} table ${table}

                ip -6 rule del from ${ip.v6} table ${table}
                ip rule del oif %i table ${table}
                ip -6 rule del oif %i table ${table}
              '';
        in
        # ini
        ''
          [Interface]
          Address = ${ip.v4}/32,${ip.v6}/128
          PrivateKey = ${config.sops.placeholder."airvpn/sk"}
          MTU = 1320
          DNS = ${dns.v4}, ${dns.v6}
          Table = ${table}
          PostUp = ${postUpFile}
          PreDown = ${preDownFile}

          [Peer]
          PublicKey = ${config.sops.placeholder."airvpn/pk"}
          PresharedKey = ${config.sops.placeholder."airvpn/psk"}
          AllowedIPs = 0.0.0.0/0,::/0
          Endpoint = ${endpoint}
          PersistentKeepalive = 15
        '';

      networking.wg-quick.interfaces.airvpn = {
        configFile = config.sops.templates."airvpn.conf".path;
        autostart = false;
      };

      systemd.services."wg-quick-airvpn".preStart = ''
        ${lib.getExe' pkgs.iproute2 "ip"} link delete airvpn || true
      '';
    };
}
