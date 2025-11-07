{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.me) user home;
in
{
  config = lib.mkIf (config.me.syncthing.enable && config.me.secrets.enable) {
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

    sops.secrets.syncthing_pw = {
      owner = user;
    };

    services.syncthing = {
      enable = true;
      inherit user;
      package = pkgs.auto.syncthing;
      dataDir = home;
      overrideDevices = true;
      overrideFolders = true;
      guiPasswordFile = config.sops.secrets.syncthing_pw.path;
      settings = {
        options = {
          urAccepted = -1;
          relaysEnabled = false;
        };
        gui.user = "admin";
      };
    };
  };
}
