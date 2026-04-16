{
  flake.nixos.pearlman =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      template = "@guiPassword@";
    in
    {
      me.services.qBittorrent = {
        subdomain = "torrent";
        port = 8080;
      };

      me.hostSecrets."qbittorrent/pw_hash" = {
        owner = config.services.qbittorrent.user;
      };

      systemd.services.qbittorrent = {
        after = [ "sops-install-secrets.service" ];
        requires = [ "sops-install-secrets.service" ];
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
          secret=$(cat "${config.sops.secrets."qbittorrent/pw_hash".path}")
          configFile=${config.services.qbittorrent.profileDir}/qBittorrent/config/qBittorrent.conf

          ${lib.getExe' pkgs.gnused "sed"} -i "s#${template}#$secret#" "$configFile"
        '';
      };

      services.qbittorrent = {
        enable = true;
        group = config.me.mediaGroup;
        package = pkgs.auto.qbittorrent-nox;
        openFirewall = true;
        serverConfig = {
          LegalNotice.Accepted = true;
          AutoRun = {
            OnTorrentAdded = {
              Enabled = true;
              Program = "systemctl start wg-quick-airvpn";
            };
          };
          BitTorrent = {
            ExcludedFileNamesEnabled = true;
            Session = {
              BTProtocol = "TCP";
              Port = config.me.vpnPort;
              DefaultSavePath = "/data/torrents";
              DisableAutoTMMByDefault = false;
              DisableAutoTMMTriggers = {
                CategorySavePathChanged = false;
                DefaultSavePathChanged = false;
              };
              ExcludedFileNames = builtins.readFile ./blacklist.txt;
              Interface = "airvpn";
              MaxConnections = 50;
              MaxConnectionsPerTorrent = 10;
              MaxUploads = 15;
              MaxUploadsPerTorrent = 4;
              Preallocation = true;
              QueueingSystemEnabled = false;
              PeXEnabled = false;
              DHTEnabled = false;
            };
          };
          Preferences = {
            Connection.ResolvePeerCountries = false;
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
                action.lookup("unit") == "wg-quick-airvpn.service" &&
                subject.user == "${config.services.qbittorrent.user}") {
              return polkit.Result.YES;
            }
          });
        '';
    };
}
