{
  lib,
  config,
  myLib,
  pkgs,
  ...
}:

let
  template = "@guiPassword@";
  portTemplate = "@port@";
in
lib.mkIf config.me.secrets.enable {
  sops.secrets."hikari/qbittorrent_pw_hash" = {
    owner = config.services.qbittorrent.user;
  };

  systemd.services.qbittorrent = {
    serviceConfig = {
      # necesarry for polkit rule to work
      RestrictAddressFamilies = lib.mkForce [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_UNIX"
      ];
    };
    preStart = ''
      secret=$(cat "${config.sops.secrets."hikari/qbittorrent_pw_hash".path}")
      port=00000
      [ -f /var/lib/proton-vpn-port ] && port=$(< /var/lib/proton-vpn-port)
      configFile=${config.services.qbittorrent.profileDir}/qBittorrent/config/qBittorrent.conf

      ${lib.getExe' pkgs.gnused "sed"} -i "s#@guiPassword@#$secret#" "$configFile"
      ${lib.getExe' pkgs.gnused "sed"} -i "s#@port@#$port#" "$configFile"
    '';
  };

  services.qbittorrent = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.auto.qbittorrent-nox;
    openFirewall = true;
    serverConfig = {
      LegalNotice.Accepted = true;
      AutoRun = {
        OnTorrentAdded = {
          Enabled = true;
          Program = "systemctl start wg-quick-proton";
        };
      };
      BitTorrent = {
        ExcludedFileNamesEnabled = true;
        Session = {
          BTProtocol = "TCP";
          Port = portTemplate;
          DefaultSavePath = "/data/torrents";
          DisableAutoTMMByDefault = false;
          DisableAutoTMMTriggers = {
            CategorySavePathChanged = false;
            DefaultSavePathChanged = false;
          };
          ExcludedFileNames = (builtins.readFile ./blacklist.txt);
          Interface = "proton";
          MaxConnections = -1;
          MaxConnectionsPerTorrent = -1;
          MaxUploads = -1;
          MaxUploadsPerTorrent = -1;
          Preallocation = true;
          QueueingSystemEnabled = false;
        };
      };
      Preferences = {
        WebUI = {
          Username = "admin";
          Password_PBKDF2 = "@ByteArray(${template})";
          CSRFProtection = false;
          ClickjackingProtection = false;
          MaxAuthenticationFailCount = 10;
        };
        General.Locale = "en";
      };
      Network = {
        PortForwardingEnabled = false;
      };
    };
  };

  security.polkit.extraConfig =
    # js
    ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "wg-quick-proton.service" &&
            subject.user == "${config.services.qbittorrent.user}") {
          return polkit.Result.YES;
        }
      });
    '';
}
