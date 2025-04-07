{
  config,
  lib,
  ...
}:

{
  disabledModules = [ "services/x11/redshift.nix" ];

  config = lib.mkIf (config.me.gui.enable && config.me.secrets.enable) {
    location.provider = "manual";

    sops.secrets.coordinates = {
      owner = config.me.user;
    };

    services.redshift = {
      enable = true;
      coordinatesFile = config.sops.secrets.coordinates.path;
      temperature = {
        night = 3000;
        day = 6500;
      };
      brightness = {
        night = "1";
        day = "1";
      };
      extraOptions = [
        "-v"
      ];
    };
  };
}
