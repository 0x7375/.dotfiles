{
  myLib,
  lib,
  config,
  ...
}:

lib.mkIf config.me.network.enable {
  networking.extraHosts =
    let
      inherit (myLib) network;
    in
    ''
      ${network.lan.addr.laptop} ryusei ryusei.local
      ${network.lan.addr.desktop} yugen yugen.local
      ${network.lan.addr.server} hikari hikari.local
    '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager.enable = true;
  users.users.${config.me.user}.extraGroups = [ "networkmanager" ];

  networking.firewall.enable = true;
}
