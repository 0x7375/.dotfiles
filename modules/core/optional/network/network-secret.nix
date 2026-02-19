{
  lib,
  mkNixos,
  config,
  secrets,
  ...
}:

lib.mkIf (config.me.secrets.enable && config.me.network.enable) (mkNixos {
  sops.secrets.networkingEnvironment = {
    sopsFile = "${secrets}/networking-environment.env";
    format = "dotenv";
    key = "";
    owner = config.me.user;
  };

  networking.networkmanager.ensureProfiles = lib.mkIf (config.me.hostname != "wilson") {
    environmentFiles = [ config.sops.secrets.networkingEnvironment.path ];
    profiles = {
      Home = {
        connection = {
          id = "home";
          type = "wifi";
        };
        wifi = {
          ssid = "$SSID_HOME";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PSK_HOME";
        };
      };
      Sekai = {
        connection = {
          id = "sekai";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "sekai";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PSK_SEKAI";
        };
      };
    };
  };
})
