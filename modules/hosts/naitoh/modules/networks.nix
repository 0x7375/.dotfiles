{
  flake.nixos.naitoh = {
    systemd.services.NetworkManager-ensure-profiles = {
      after = [ "sops-install-secrets.service" ];
      requires = [ "sops-install-secrets.service" ];
    };

    networking.networkmanager.ensureProfiles.profiles = {
      away_1 = {
        connection = {
          id = "away_1";
          type = "wifi";
        };
        wifi = {
          ssid = "$SSID_AWAY_1";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PSK_AWAY_1";
        };
      };
      away_2 = {
        connection = {
          id = "away_2";
          type = "wifi";
        };
        wifi = {
          ssid = "$SSID_AWAY_2";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PSK_AWAY_2";
        };
      };
      eduroam = {
        "802-1x" = {
          anonymous-identity = "anonymous@unicaen.fr";
          eap = "ttls;";
          identity = "$USER_EDUROAM";
          password = "$PSK_EDUROAM";
          phase2-auth = "mschapv2";
        };
        connection = {
          id = "eduroam";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "eduroam";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-eap";
        };
      };
    };
  };
}
