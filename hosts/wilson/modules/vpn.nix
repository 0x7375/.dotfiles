{
  lib,
  config,
  ...
}:

let
  home = "home";
  inherit (config.me) hostname hosts;
  wgPort = 51820;
in
lib.mkIf config.me.secrets.enable {
  sops.secrets."${hostname}/vpn/pk".owner = config.me.user;

  sops.secrets."mach/vpn/psk".owner = config.me.user;
  sops.secrets."naitoh/vpn/psk".owner = config.me.user;
  sops.secrets."shannon/vpn/psk".owner = config.me.user;
  sops.secrets."lamarr/vpn/psk".owner = config.me.user;

  # redirect clients network traffic to the VPN
  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = [ home ];
  #   externalInterface = "end0";
  # };

  networking.firewall.allowedUDPPorts = [ wgPort ];

  networking.wg-quick.interfaces.${home} = {
    address = [ "${hosts.${hostname}.ips.vpn}/24" ];
    listenPort = wgPort;
    privateKeyFile = config.sops.secrets."${hostname}/vpn/pk".path;

    peers =
      let
        inherit (hosts)
          naitoh
          shannon
          lamarr
          mach
          ;
      in
      [
        {
          publicKey = "apB8TVyEJ7G/gLe5b3ckvUYJSSKv85rl1jWkZoiEQgE=";
          presharedKeyFile = config.sops.secrets."naitoh/vpn/psk".path;
          allowedIPs = [ "${naitoh.ips.vpn}/32" ];
        }
        {
          publicKey = "mEN17hfodGLbe58cS6r7qeegmeQlSebz2JCUIlsWdn0=";
          presharedKeyFile = config.sops.secrets."shannon/vpn/psk".path;
          allowedIPs = [ "${shannon.ips.vpn}/32" ];
        }
        {
          publicKey = "vEKQ3Lpxn8JScQRMS8t6lq6dGWXiB9oyBgr2gSTfvxA=";
          presharedKeyFile = config.sops.secrets."lamarr/vpn/psk".path;
          allowedIPs = [ "${lamarr.ips.vpn}/32" ];
        }
        {
          publicKey = "z2/QJTGzNBiq4MKPqFDtuPJsCE1Tb/7VG6oYCExeYVg=";
          presharedKeyFile = config.sops.secrets."mach/vpn/psk".path;
          allowedIPs = [ "${mach.ips.vpn}/32" ];
        }
      ];
  };
}
