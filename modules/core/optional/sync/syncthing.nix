{
  mkNixos,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.me) user home hostname;
in
{
  config = lib.mkIf (config.me.syncthing.enable && config.me.secrets.enable) (mkNixos {
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

    sops.secrets."${hostname}/syncthing/cert".owner = config.me.user;
    sops.secrets."${hostname}/syncthing/key".owner = config.me.user;

    sops.secrets.syncthing_pw.owner = user;

    services.syncthing = {
      enable = true;
      inherit user;
      package = pkgs.auto.syncthing;
      dataDir = home;
      overrideDevices = true;
      overrideFolders = true;
      guiPasswordFile = config.sops.secrets.syncthing_pw.path;
      key = "${config.sops.secrets."${hostname}/syncthing/key".path}";
      cert = "${config.sops.secrets."${hostname}/syncthing/cert".path}";
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
