{
  mkNixos,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.me) user hostname;
  mkHostSecret = lib.my.mkHostSecret hostname;
in
{
  config = lib.mkIf (config.me.syncthing.enable && config.me.secrets.enable) (mkNixos {
    sops.secrets."syncthing/key" = mkHostSecret "syncthing/key" { owner = user; };

    sops.secrets.syncthing_pw.owner = user;

    services.syncthing = {
      enable = true;
      package = pkgs.auto.syncthing;
      overrideDevices = true;
      overrideFolders = true;
      guiPasswordFile = config.sops.secrets.syncthing_pw.path;
      key = "${config.sops.secrets."syncthing/key".path}";
      cert = "${pkgs.writeText "cert" ''
        -----BEGIN CERTIFICATE-----
        ${config.me.host.syncthing.cert}
        -----END CERTIFICATE-----
      ''}";
      settings = {
        options = {
          urAccepted = -1;
          relaysEnabled = false;
        };
        gui.user = "admin";
      };
    };
  });
}
