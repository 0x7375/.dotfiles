{
  lib,
  myLib,
  pkgs,
  config,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets."proton_vpn/endpoint" = { };
  sops.secrets."proton_vpn/pk" = { };

  sops.templates."proton-vpn.conf".content =
    let
      inherit (myLib) network;
      writeScriptFile = name: text: ((pkgs.writeShellScriptBin name text) + "/bin/${name}");
      postUpFile = writeScriptFile "postUp.sh" ''
        ip rule add from ${network.vpn.subnet} lookup main priority 100
        ip rule add to ${network.vpn.subnet} lookup main priority 100

        ip rule add from ${network.lan.subnet} lookup main priority 100
        ip rule add to ${network.lan.subnet} lookup main priority 100
      '';
      preDownFile = writeScriptFile "preDown.sh" ''
        ip rule del from ${network.vpn.subnet} lookup main priority 100
        ip rule del to ${network.vpn.subnet} lookup main priority 100

        ip rule del from ${network.lan.subnet} lookup main priority 100
        ip rule del to ${network.lan.subnet} lookup main priority 100
      '';
    in
    # ini
    ''
      [Interface]
      Address = 10.2.0.2/32
      PrivateKey = ${config.sops.placeholder."proton_vpn/pk"}
      ListenPort = 0
      PostUp = ${postUpFile}
      PreDown = ${preDownFile}

      [Peer]
      PublicKey = wYsaKyJteQ1gYoJZAZT0FettXDOidPhQZwl0DhaabF0=
      AllowedIPs = 0.0.0.0/0,::/0
      Endpoint = ${config.sops.placeholder."proton_vpn/endpoint"}:51820
    '';

  networking.wg-quick.interfaces.proton = {
    configFile = config.sops.templates."proton-vpn.conf".path;
    autostart = false;
  };
}
