{
  lib,
  myLib,
  pkgs,
  config,
  ...
}:

let
  gw-ip = "10.2.0.1";
in
lib.mkIf config.me.secrets.enable {
  sops.secrets."proton_vpn/endpoint" = { };
  sops.secrets."proton_vpn/pk" = { };
  sops.secrets."proton_vpn/sk" = { };

  sops.templates."proton-vpn.conf".content =
    let
      inherit (myLib) network;
      writeScriptFile = name: text: ((pkgs.writeShellScriptBin name text) + "/bin/${name}");
      server = config.me.hostname == "hikari";
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
            ip rule add from ${network.vpn.subnet} lookup main priority 100
            ip rule add to ${network.vpn.subnet} lookup main priority 100

            ip rule add from ${network.lan.subnet} lookup main priority 100
            ip rule add to ${network.lan.subnet} lookup main priority 100
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
            ip rule del from ${network.vpn.subnet} lookup main priority 100
            ip rule del to ${network.vpn.subnet} lookup main priority 100

            ip rule del from ${network.lan.subnet} lookup main priority 100
            ip rule del to ${network.lan.subnet} lookup main priority 100
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

  systemd.services."proton-portforward" = {
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    bindsTo = [ "wg-quick-proton.service" ];

    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "get-proton-port" ''
        OUTPUT=$(${pkgs.libnatpmp}/bin/natpmpc -g ${gw-ip} -a 1 0 tcp 60 2>/dev/null)
        PORT=$(echo "$OUTPUT" | ${pkgs.gawk}/bin/awk '/Mapped public port/ {print $4}')

        if [ -n "$PORT" ]; then
          echo "$PORT" > /tmp/proton-vpn-port
          echo "Successfully got port: $PORT"
        fi
      '';

      ExecStart = pkgs.writeShellScript "renew-proton-port" ''
        while true; do
          ${pkgs.libnatpmp}/bin/natpmpc -g ${gw-ip} -a 1 0 tcp 60 >/dev/null 2>&1
          ${pkgs.libnatpmp}/bin/natpmpc -g ${gw-ip} -a 1 0 udp 60 >/dev/null 2>&1
          echo "Port forwarding renewed"
          sleep 45
        done
      '';
    };
  };
}
