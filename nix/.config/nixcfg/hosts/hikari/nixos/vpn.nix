{
  lib,
  myLib,
  config,
  ...
}:

let
  home = "home";
in
lib.mkIf config.me.secrets.enable {
  sops.secrets."hikari/server_vpn_pk".owner = config.me.user;
  sops.secrets.laptop_vpn_psk.owner = config.me.user;
  sops.secrets.phone_vpn_psk.owner = config.me.user;

  # redirect clients network traffic to the VPN
  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = [ home ];
  #   externalInterface = "end0";
  # };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wg-quick.interfaces.${home} =
    let
      inherit (myLib) network;
    in
    {
      address = [ "${network.vpn.addr.server}/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."hikari/server_vpn_pk".path;

      peers = [
        # laptop
        {
          publicKey = "apB8TVyEJ7G/gLe5b3ckvUYJSSKv85rl1jWkZoiEQgE=";
          presharedKeyFile = config.sops.secrets.laptop_vpn_psk.path;
          allowedIPs = [ "${network.vpn.addr.laptop}/32" ];
        }
        # phone
        {
          publicKey = "mEN17hfodGLbe58cS6r7qeegmeQlSebz2JCUIlsWdn0=";
          presharedKeyFile = config.sops.secrets.phone_vpn_psk.path;
          allowedIPs = [ "${network.vpn.addr.phone}/32" ];
        }
      ];
    };
}
