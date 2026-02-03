{ lib, secrets, config, ... }:

let
  cfg = config.me;
  mkSyncthingSecret = filename: {
    owner = cfg.user;
    sopsFile = "${secrets}/syncthing/${filename}";
    format = "binary";
    key = "";
  };
in
lib.mkIf config.me.secrets.enable {
  sops.secrets."syncthing/config" = mkSyncthingSecret "config.xml";
  sops.secrets."syncthing/cert" = mkSyncthingSecret "cert.pem";
  sops.secrets."syncthing/key" = mkSyncthingSecret "key.pem";

  activation =
    let
      inherit (config.sops) secrets;
      inherit (cfg) home;
    in
    ''
      stDir="${home}/Library/Application Support/Syncthing"
      mkdir -p "${home}/Library/Application Support/Syncthing"

      cp -f ${secrets."syncthing/config".path} "$stDir/config.xml"
      cp -f ${secrets."syncthing/key".path} "$stDir/key.pem"
      cp -f ${secrets."syncthing/cert".path} "$stDir/cert.pem"

      chown -R ${cfg.user}: "$stDir"
      chmod 600 "$stDir/config.xml" "$stDir/key.pem" "$stDir/cert.pem"
    '';
}
