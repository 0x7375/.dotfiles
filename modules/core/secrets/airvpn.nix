{
  lib,
  pkgs,
  config,
  mkNixos,
  ...
}:

let
  inherit (config.me) secrets hostname server;
  isServer = hostname == server;
in
lib.mkIf secrets.enable (
  mkNixos (
    lib.mkMerge [
      {
        sops.secrets."airvpn/pk" = { };
        sops.secrets."airvpn/sk" = { };
        sops.secrets."airvpn/psk" = { };

        sops.templates."airvpn.conf".content =
          let
            writeScriptFile = name: text: ((pkgs.writeShellScriptBin name text) + "/bin/${name}");
            gw-ip = "10.128.0.1";
            ip = "10.159.130.32";
            ipv6 = "fd7d:76ee:e68f:a993:e922:4b96:c567:bca5";
            table = "200";
            postUpFile = writeScriptFile "postUp.sh" ''
              ip route add ${gw-ip} dev airvpn
              ip rule add from ${ip} table ${table}

              ip -6 rule add from ${ipv6} table ${table}
              ip rule add oif %i table ${table}
              ip -6 rule add oif %i table ${table}
            '';
            preDownFile = writeScriptFile "preDown.sh" ''
              ip route del ${gw-ip} dev airvpn
              ip rule del from ${ip} table ${table}

              ip -6 rule del from ${ipv6} table ${table}
              ip rule del oif %i table ${table}
              ip -6 rule del oif %i table ${table}
            '';
          in
          ''
            [Interface]
            Address = ${ip}/32,${ipv6}/128
            PrivateKey = ${config.sops.placeholder."airvpn/sk"}
            MTU = 1320
            DNS = 10.128.0.1, fd7d:76ee:e68f:a993::1
            ${
              if isServer then
                ''
                  Table = ${table}
                  PostUp = ${postUpFile}
                  PreDown = ${preDownFile}
                ''
              else
                ""
            }

            [Peer]
            PublicKey = ${config.sops.placeholder."airvpn/pk"}
            PresharedKey = ${config.sops.placeholder."airvpn/psk"}
            AllowedIPs = 0.0.0.0/0,::/0
            Endpoint = europe.vpn.airdns.org:1637
            PersistentKeepalive = 15
          '';

        networking.wg-quick.interfaces.airvpn = {
          configFile = config.sops.templates."airvpn.conf".path;
          autostart = false;
        };

        networking.firewall.interfaces.airvpn =
          let
            inherit (config.me) vpnPort;
          in
          lib.mkIf isServer {
            allowedTCPPorts = [ vpnPort ];
            allowedUDPPorts = [ vpnPort ];
          };

        systemd.services."wg-quick-airvpn".preStart = ''
          ${lib.getExe' pkgs.iproute2 "ip"} link delete airvpn || true
        '';

        boot.kernel.sysctl = {
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
        };
      }
    ]
  )
)
