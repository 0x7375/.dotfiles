{
  lib,
  pkgs,
  config,
  mkNixos,
  ...
}:

let
  inherit (lib) getExe getExe';
  gw-ip = "10.2.0.1";
  server = config.me.hostname == "wilson";
  inherit (config.me) secrets hostname;
in
lib.mkIf secrets.enable (
  mkNixos (
    lib.mkMerge [
      {
        sops.secrets."proton_vpn/endpoint" = { };
        sops.secrets."proton_vpn/pk" = { };
        sops.secrets."proton_vpn/sk" = { };

        sops.templates."proton-vpn.conf".content =
          let
            inherit (config.me) networkIps;
            writeScriptFile = name: text: ((pkgs.writeShellScriptBin name text) + "/bin/${name}");
            ip = "10.2.0.2";
            table = "200";
            postUpFile = writeScriptFile "postUp.sh" (
              if server then
                # bash
                ''
                  ip route add ${gw-ip} dev proton
                  ip rule add from ${ip} table ${table}
                  ip rule add oif %i table ${table}
                ''
              else
                # bash
                ''
                  ip rule add from ${networkIps.vpn.subnet} lookup main priority 100
                  ip rule add to ${networkIps.vpn.subnet} lookup main priority 100

                  ip rule add from ${networkIps.lan.subnet} lookup main priority 100
                  ip rule add to ${networkIps.lan.subnet} lookup main priority 100
                ''
            );
            preDownFile = writeScriptFile "preDown.sh" (
              if server then
                # bash
                ''
                  ip route del ${gw-ip} dev proton
                  ip rule del from ${ip} table ${table}
                  ip rule del oif %i table ${table}
                ''
              else
                # bash
                ''
                  ip rule del from ${networkIps.vpn.subnet} lookup main priority 100
                  ip rule del to ${networkIps.vpn.subnet} lookup main priority 100

                  ip rule del from ${networkIps.lan.subnet} lookup main priority 100
                  ip rule del to ${networkIps.lan.subnet} lookup main priority 100
                ''
            );
          in
          # ini
          ''
            [Interface]
            Address = ${ip}/32
            PrivateKey = ${config.sops.placeholder."proton_vpn/sk"}
            ListenPort = 0
            ${if server then "Table = ${table}" else ""}
            PostUp = ${postUpFile}
            PreDown = ${preDownFile}

            [Peer]
            PublicKey = ${config.sops.placeholder."proton_vpn/pk"}
            AllowedIPs = 0.0.0.0/0,::/0
            Endpoint = ${config.sops.placeholder."proton_vpn/endpoint"}:51820
          '';

        networking.wg-quick.interfaces.proton = {
          configFile = config.sops.templates."proton-vpn.conf".path;
          autostart = false;
        };

        systemd.services."wg-quick-proton".preStart = ''
          ${pkgs.iproute2}/bin/ip link delete proton 2>/dev/null || true
        '';

        boot.kernel.sysctl = {
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
        };
      }
      (lib.mkIf server {
        sops.secrets."qbittorrent/pw" = lib.my.mkHostSecret hostname "qbittorrent/pw" {
          owner = config.services.qbittorrent.user;
        };

        systemd.services."proton-portforward" = {
          after = [
            "network-online.target"
            "wg-quick-proton.service"
            "qbittorrent.service"
          ];
          wants = [
            "network-online.target"
            "qbittorrent.service"
          ];
          bindsTo = [ "wg-quick-proton.service" ];
          wantedBy = [ "wg-quick-proton.service" ];

          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "5s";
            LoadCredential = [ "password:${config.sops.secrets."qbittorrent/pw".path}" ];
            ExecStartPre = pkgs.writeShellScript "get-proton-port" (
              let
                inherit (config.me.services.qBittorrent) port;
              in
              # bash
              ''
                OUTPUT=$(${getExe' pkgs.libnatpmp "natpmpc"} -g ${gw-ip} -a 1 0 tcp 60 2>/dev/null)
                PORT=$(echo "$OUTPUT" | ${getExe' pkgs.gawk "awk"} '/Mapped public port/ {print $4}')

                if [ -n "$PORT" ]; then
                  if [ -f /var/lib/proton-vpn-port ] && [ "$(< /var/lib/proton-vpn-port)" == "$PORT" ]; then
                    echo "Port unchanged: $PORT"
                  else
                    echo "$PORT" > /var/lib/proton-vpn-port
                    echo "Successfully got new port: $PORT"
                    
                    if systemctl is-active --quiet qbittorrent; then
                      PASS=$(cat "$CREDENTIALS_DIRECTORY/password")
                      SID=$(${getExe pkgs.curl} -s -i -X POST "http://localhost:${toString port}/api/v2/auth/login" \
                        --data "username=admin&password=$PASS" | grep -i set-cookie | sed 's/.*SID=\([^;]*\);.*/\1/')
                      
                        ${getExe pkgs.curl} -s -X POST "http://localhost:${toString port}/api/v2/app/setPreferences" \
                          -H "Content-Type: application/x-www-form-urlencoded" \
                          -H "Cookie: SID=$SID" \
                          --data "json={\"listen_port\":$PORT}" && echo "qBittorrent port updated to $PORT"
                    else
                      echo "qBittorrent not running, skipping port update"
                    fi
                  fi
                fi
              ''
            );

            ExecStart = pkgs.writeShellScript "renew-proton-port" ''
              PORT=$(< /var/lib/proton-vpn-port)
              while true; do
                if ! ${getExe' pkgs.nftables "nft"} list chain inet nixos-fw input | grep -q "tcp dport $PORT accept"; then
                  ${getExe' pkgs.nftables "nft"} insert rule inet nixos-fw input iifname "proton" tcp dport "$PORT" accept
                  ${getExe' pkgs.nftables "nft"} insert rule inet nixos-fw input iifname "proton" udp dport "$PORT" accept
                  echo "Port $PORT inserted into filter table"
                fi

                ${getExe' pkgs.libnatpmp "natpmpc"} -g ${gw-ip} -a 1 0 tcp 60 >/dev/null 2>&1
                ${getExe' pkgs.libnatpmp "natpmpc"} -g ${gw-ip} -a 1 0 udp 60 >/dev/null 2>&1
                echo "Port forwarding renewed"
                sleep 45
              done
            '';
          };
        };
      })
    ]
  )
)
