{
  networking.networkmanager.ensureProfiles.profiles = {
    Away_1 = {
      connection = {
        id = "Away_1";
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
    Away_2 = {
      connection = {
        id = "Away_2";
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
    Eduroam = {
      "802-1x" = {
        anonymous-identity = "anonymous@unicaen.fr";
        eap = "ttls;";
        identity = "$USER_EDUROAM";
        password = "$PSK_EDUROAM";
        phase2-auth = "mschapv2";
      };
      connection = {
        id = "Eduroam";
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
}
