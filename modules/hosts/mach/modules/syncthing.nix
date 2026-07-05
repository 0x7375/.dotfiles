{
  flake.modules.darwin.mach =
    {
      secrets,
      config,
      lib,
      ...
    }:
    let
      inherit (config.me) user home;
    in
    {
      sops.secrets."syncthing/config" = {
        owner = user;
        sopsFile = "${secrets}/mach/config.xml";
        format = "binary";
        key = "";
      };

      me.hostSecrets."syncthing/key" = {
        owner = user;
      };

      system.activationScripts.postActivation.text =
        let
          inherit (config.sops) secrets;
        in
        # bash
        lib.mkAfter ''
          dir="${home}/Library/Application Support/Syncthing"
          mkdir -p "$dir"

          cp -f ${secrets."syncthing/config".path} "$dir/config.xml"
          cp -f ${secrets."syncthing/key".path} "$dir/key.pem"

          cat << 'EOF' > "$dir/cert.pem"
          -----BEGIN CERTIFICATE-----
          ${config.me.host.syncthing.cert}
          -----END CERTIFICATE-----
          EOF

          chown -R ${user}: "$dir"
          chmod 600 "$dir/config.xml" "$dir/key.pem" "$dir/cert.pem"
        '';
    };
}
