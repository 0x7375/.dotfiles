{
  flake.darwin.mach =
    {
      lib,
      secrets,
      config,
      ...
    }:
    let
      inherit (config.me) user home hostname;
      mkHostSecret = lib.my.mkHostSecret hostname;
    in
    {
      sops.secrets."syncthing/config" = {
        owner = user;
        sopsFile = "${secrets}/mach/config.xml";
        format = "binary";
        key = "";
      };

      sops.secrets."syncthing/key" = mkHostSecret "syncthing/key" { owner = user; };
      hj.files."Library/Application Support/Syncthing/cert.pem".text = ''
        -----BEGIN CERTIFICATE-----
        ${config.me.host.syncthing.cert}
        -----END CERTIFICATE-----
      '';

      system.activationScripts.sshConfigFromSecrets = {
        deps = [ "setupSecrets" ];
        text =
          let
            inherit (config.sops) secrets;
          in
          # bash
          ''
            dir="${home}/Library/Application Support/Syncthing"
            mkdir -p "${home}/Library/Application Support/Syncthing"

            cp -f ${secrets."syncthing/config".path} "$dir/config.xml"
            cp -f ${secrets."syncthing/key".path} "$dir/key.pem"

            chown -R ${user}: "$dir"
            chmod 600 "$dir/config.xml" "$dir/key.pem"
          '';
      };
    };
}
