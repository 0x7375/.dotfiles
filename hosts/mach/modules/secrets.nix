{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.me) hostname hosts;
in
lib.mkIf config.me.secrets.enable {
  # TODO: Refactor laptops wireguard config
  sops.secrets."${hostname}/vpn/pk".owner = config.me.user;
  sops.secrets."${hostname}/vpn/psk".owner = config.me.user;

  sops.templates."home-vpn-mach.conf".content =
    let
      inherit (config.me) networkIps;
    in
    ''
      [Interface]
      Address = ${hosts.${hostname}.ips.vpn}/24
      PrivateKey = ${config.sops.placeholder."${hostname}/vpn/pk"}

      [Peer]
      PublicKey = z2/QJTGzNBiq4MKPqFDtuPJsCE1Tb/7VG6oYCExeYVg=
      PresharedKey = ${config.sops.placeholder."${hostname}/vpn/psk"}
      AllowedIPs = ${networkIps.vpn.subnet},${networkIps.lan.subnet}
      Endpoint = ${config.sops.placeholder.server_vpn_endpoint}
    '';

  packages = [ pkgs.wireguard-tools ];

  # TODO: world readable mon gars
  # environment.etc."wireguard/home.conf".source = config.sops.templates."home-vpn-mach.conf".path;
}
