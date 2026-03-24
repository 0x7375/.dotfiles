{ self, ... }:

{
  flake.nixos.pearlman =
    {
      secrets,
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (config.me) hostname;
    in
    {
      packages = with pkgs; [
        rclone
        restic
      ];

      me.hostSecrets."restic_pw" = { };

      sops.secrets.rclone_config = {
        sopsFile = "${secrets}/${hostname}/rclone-config.ini";
        format = "ini";
      };

      vars.RESTIC_PASSWORD_FILE = config.sops.secrets."restic_pw".path;

      services.restic.backups =
        let
          mediaDirs = [
            config.services.jellyfin.dataDir
            (config.services.qbittorrent.profileDir + "/qBittorrent")
            config.services.radarr.dataDir
            config.services.sonarr.dataDir
            config.services.prowlarr.dataDir
            config.services.bazarr.dataDir
            "/var/lib/cleanuparr"
            "/var/lib/seerr"
          ];

          backupConfig =
            let
              remotes = {
                local = {
                  time = "18:00:00";
                  path = "/mnt/ssd/backups/restic/";
                };
                backblaze = {
                  time = "22:00:00";
                  path = "rclone:backblaze:restic9678412/";
                };
              };
            in
            {
              remote,
              day,
              paths,
              name,
              exclude,
            }:
            {
              initialize = true;
              passwordFile = config.sops.secrets."restic_pw".path;
              rcloneConfigFile = config.sops.secrets.rclone_config.path;
              repository = remotes.${remote}.path + name;
              inherit paths;
              inherit exclude;
              pruneOpts = [
                "--keep-weekly 4"
                "--keep-monthly 6"
              ];
              timerConfig = {
                OnCalendar = day + " *-*-* " + remotes.${remote}.time;
                Persistent = true;
              };
              rcloneOptions = {
                "fast-list" = "true"; # single api call to list every directory
                "transfers" = "50";
              };
            };

          createBackups =
            name:
            {
              paths,
              day,
              exclude ? [ ],
            }:
            builtins.listToAttrs (
              map
                (remote: {
                  name = "${remote}-${name}";
                  value = backupConfig {
                    inherit
                      remote
                      day
                      paths
                      name
                      exclude
                      ;
                  };
                })
                [
                  "local"
                  "backblaze"
                ]
            );
        in
        (createBackups "syncthing" {
          paths = [ "/mnt/ssd/syncthing" ];
          day = "Sat";
          exclude = [
            ".stfolder"
            ".stversions"
            ".stignore"
          ];
        })
        // (createBackups "media" {
          paths = mediaDirs;
          day = "Sun";
        })
        // (createBackups "git" {
          paths = [ "/mnt/ssd/backups/git" ];
          day = "Mon";
        });

      systemd.services = lib.mkMerge (
        map (service: self.lib.notifyOnServiceFailure ("restic-backups-" + service)) (
          builtins.attrNames config.services.restic.backups
        )
      );
    };
}
