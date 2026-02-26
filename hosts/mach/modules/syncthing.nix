{
  lib,
  secrets,
  config,
  ...
}:

let
  inherit (config.me) user home;
  inherit (lib.my) mkHostSecret;

in
lib.mkIf config.me.secrets.enable {
  sops.secrets."syncthing/config" = {
    owner = user;
    sopsFile = "${secrets}/mach/config.xml";
    format = "binary";
    key = "";
  };

  sops.secrets."syncthing/cert" = mkHostSecret "syncthing/cert" { owner = user; };
  sops.secrets."syncthing/key" = mkHostSecret "syncthing/cert" { owner = user; };

  activation =
    let
      inherit (config.sops) secrets;
    in
    ''
      stDir="${home}/Library/Application Support/Syncthing"
      mkdir -p "${home}/Library/Application Support/Syncthing"

      cp -f ${secrets."syncthing/config".path} "$stDir/config.xml"
      cp -f ${secrets."syncthing/key".path} "$stDir/key.pem"
      cp -f ${secrets."syncthing/cert".path} "$stDir/cert.pem"

      chown -R ${user}: "$stDir"
      chmod 600 "$stDir/config.xml" "$stDir/key.pem" "$stDir/cert.pem"
    '';
}
