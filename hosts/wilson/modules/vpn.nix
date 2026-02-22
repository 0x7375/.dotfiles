{
  lib,
  config,
  ...
}:

let
  home = "home";
  inherit (config.me) hostname hosts host;
  wgPort = 51820;

  peerKeys = {
    naitoh = "apB8TVyEJ7G/gLe5b3ckvUYJSSKv85rl1jWkZoiEQgE=";
    shannon = "mEN17hfodGLbe58cS6r7qeegmeQlSebz2JCUIlsWdn0=";
    lamarr = "vEKQ3Lpxn8JScQRMS8t6lq6dGWXiB9oyBgr2gSTfvxA=";
    mach = "z2/QJTGzNBiq4MKPqFDtuPJsCE1Tb/7VG6oYCExeYVg=";
    yoshino = "+TLwV2JKgqxaAHBv/BYrwDXEcILUt3cbuth1XY/HfTo=";
  };

  peerNames = builtins.attrNames peerKeys;
in
lib.mkIf config.me.secrets.enable {
  sops.secrets =
    let
      mkPskSecret = name: {
        name = "${name}/vpn/psk";
        value = {
          owner = config.me.user;
        };
      };
    in
    {
      "${hostname}/vpn/pk".owner = config.me.user;
    }
    // (builtins.listToAttrs (map mkPskSecret peerNames));

  # redirect clients network traffic to the VPN
  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = [ home ];
  #   externalInterface = "end0";
  # };

  networking.firewall.allowedUDPPorts = [ wgPort ];

  networking.nftables.tables.restrict-to-koffan = {
    family = "inet";
    content = ''
      set restricted_peer {
        type ipv4_addr
        elements = { ${hosts.yoshino.ips.vpn} }
      }

      chain enforce_input {
        type filter hook input priority -10; policy accept;
        ip saddr @restricted_peer tcp dport 3000 accept
        ip saddr @restricted_peer drop
      }

      chain enforce_forward {
        type filter hook forward priority -10; policy accept;
        ip saddr @restricted_peer ct original protocol tcp ct original proto-dst 3000 accept
        ip saddr @restricted_peer drop
      }
    '';
  };

  networking.wg-quick.interfaces.${home} = {
    address = [ "${host.ips.vpn}/24" ];
    listenPort = wgPort;
    privateKeyFile = config.sops.secrets."${hostname}/vpn/pk".path;

    peers = lib.mapAttrsToList (name: pubKey: {
      publicKey = pubKey;
      presharedKeyFile = config.sops.secrets."${name}/vpn/psk".path;
      allowedIPs = [ "${hosts.${name}.ips.vpn}/32" ];
    }) peerKeys;
  };
}
