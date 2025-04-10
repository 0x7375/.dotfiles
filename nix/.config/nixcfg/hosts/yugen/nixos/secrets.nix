{ lib, config, ... }:

lib.mkIf config.me.secrets.enable {
  sops.secrets."yugen/syncthing/cert" = {
    owner = config.me.user;
  };

  sops.secrets."yugen/syncthing/key" = {
    owner = config.me.user;
  };

  services.syncthing = {
    cert = "${config.sops.secrets."yugen/syncthing/cert".path}";
    key = "${config.sops.secrets."yugen/syncthing/key".path}";
  };

}
