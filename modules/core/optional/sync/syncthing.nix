{
  mkNixos,
  lib,
  pkgs,
  config,
  ...
}:

{
  config = lib.mkIf (config.me.syncthing.enable && config.me.secrets.enable) (mkNixos {
    systemd.services.syncthing = {
      after = [ "sops-install-secrets.service" ];
      requires = [ "sops-install-secrets.service" ];
    };

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
