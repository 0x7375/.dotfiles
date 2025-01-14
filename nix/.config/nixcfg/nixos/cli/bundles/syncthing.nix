{
  secrets,
  lib,
  config,
  ...
}:

let
  user = config.me.user;
in
lib.mkIf (config.me.syncthing.enable && config.me.secrets.enable) {
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

  sops.secrets.syncthing_pw = {
    owner = user;
  };

  services.syncthing = {
    enable = true;
    inherit user;
    dataDir = "/home/${user}";
    overrideDevices = true;
    overrideFolders = true;
    guiPasswordFile = if config.me.secrets.enable then config.sops.secrets.syncthing_pw.path else null;
    settings = {
      options = {
        urAccepted = -1;
      };
      gui.user = "admin";
    };
  };
}
