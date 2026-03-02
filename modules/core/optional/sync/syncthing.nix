{
  mkNixos,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.me) user home hostname;
  mkHostSecret = lib.my.mkHostSecret hostname;
in
{
  config = lib.mkIf (config.me.syncthing.enable && config.me.secrets.enable) (mkNixos {
    sops.secrets."syncthing/cert" = mkHostSecret "syncthing/cert" { owner = user; };
    sops.secrets."syncthing/key" = mkHostSecret "syncthing/key" { owner = user; };

    sops.secrets.syncthing_pw.owner = user;

    services.syncthing = {
      enable = true;
      inherit user;
      package = pkgs.auto.syncthing;
      dataDir = home;
      overrideDevices = true;
      overrideFolders = true;
      guiPasswordFile = config.sops.secrets.syncthing_pw.path;
      key = "${config.sops.secrets."syncthing/key".path}";
      cert = "${config.sops.secrets."syncthing/cert".path}";
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
