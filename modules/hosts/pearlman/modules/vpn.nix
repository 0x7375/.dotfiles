{
  flake.modules.nixos.pearlman =
    {
      lib,
      config,
      ...
    }:
    let
      home = "home";
      inherit (config.me)
        hosts
        host
        ;
      wgPort = 1637;

      peerKeys = {
        naitoh = "apB8TVyEJ7G/gLe5b3ckvUYJSSKv85rl1jWkZoiEQgE=";
        shannon = "D3+XcAKleaWTA8FNUprJTmqqHnG9K9wLKnZs2/K9mGo=";
        lamarr = "vEKQ3Lpxn8JScQRMS8t6lq6dGWXiB9oyBgr2gSTfvxA=";
        mach = "z2/QJTGzNBiq4MKPqFDtuPJsCE1Tb/7VG6oYCExeYVg=";
        yoshino = "+TLwV2JKgqxaAHBv/BYrwDXEcILUt3cbuth1XY/HfTo=";
        cray = "IZKATLv0/+V137IYJJpw7I2qVbilaSQnaFMfj9zlmBc=";
        woz = "MB9Q6MhSciYep8uHV2YHkKiwFYA0qr+Ugw1ZlHqq1Qc=";
      };

      peerNames = builtins.attrNames peerKeys;

    in
    {
      me.hostSecrets."vpn/pk" = {
        owner = config.me.user;
      };
      sops.secrets = builtins.listToAttrs (
        map (name: {
          name = "${name}/vpn/psk";
          value = {
            owner = config.me.user;
          };
        }) peerNames
      );

      # redirect clients wan traffic to the VPN
      # networking.nat = {
      #   enable = true;
      #   internalInterfaces = [ home ];
      #   externalInterface = "end0";
      # };

      networking.firewall.allowedUDPPorts = [ wgPort ];

      networking.wg-quick.interfaces.${home} = {
        address = [ "${host.ips.vpn}/24" ];
        listenPort = wgPort;
        privateKeyFile = config.sops.secrets."vpn/pk".path;

        peers = lib.mapAttrsToList (name: pubKey: {
          publicKey = pubKey;
          presharedKeyFile = config.sops.secrets."${name}/vpn/psk".path;
          allowedIPs = [ "${hosts.${name}.ips.vpn}/32" ];
        }) peerKeys;
      };
    };
}
