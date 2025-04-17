{
  myLib,
  lib,
  config,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets."ryusei/syncthing/cert" = {
    owner = config.me.user;
  };

  sops.secrets."ryusei/syncthing/key" = {
    owner = config.me.user;
  };

  services.syncthing = lib.mkIf config.me.secrets.enable {
    key = "${config.sops.secrets."ryusei/syncthing/key".path}";
    cert = "${config.sops.secrets."ryusei/syncthing/cert".path}";
  };

  sops.secrets."ryusei/laptop_vpn_pk" = {
    owner = config.me.user;
  };

  sops.templates."home-vpn-laptop.conf".content =
    let
      inherit (myLib) network;
    in
    ''
      [Interface]
      Address = ${network.vpn.addr.laptop}/24
      PrivateKey = ${config.sops.placeholder."ryusei/laptop_vpn_pk"}

      [Peer]
      PublicKey = PpCxUOTz7Heh3B29OnI3XNZAKJ8abUETMzFNj3gpTyo=
      PresharedKey = ${config.sops.placeholder."laptop_vpn_psk"}
      AllowedIPs = ${network.vpn.subnet},${network.lan.subnet}
      Endpoint = ${config.sops.placeholder.server_vpn_endpoint}
    '';

  networking.wg-quick.interfaces.home = {
    autostart = false;
    configFile = config.sops.templates."home-vpn-laptop.conf".path;
  };
}
