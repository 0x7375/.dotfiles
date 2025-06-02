{
  myLib,
  secrets,
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  environment.systemPackages = with pkgs; [
    rclone
    restic
  ];

  sops.secrets."hikari/restic_pw" = { };

  sops.secrets.rclone_config = {
    sopsFile = "${secrets}/rclone-config.ini";
    format = "ini";
  };

  services.restic.backups =
    let
      syncthingDirs = map (path: "/home/${config.me.user}/${path}") [
        "documents"
        "games/ds"
        "perso"
        "photos"
        "pictures"
        "uni"
        "notes"
        "windows"
      ];

      mediaDirs = [
        config.services.jellyseerr.configDir
        config.services.jellyfin.dataDir
        config.services.qBittorrent.dataDir
        config.services.radarr.dataDir
        config.services.sonarr.dataDir
        config.services.prowlarr.dataDir
        config.services.bazarr.dataDir
      ];

      gitRepos = [
        "/home/${config.me.user}/git"
      ];

      androidBackup = [
        "/srv/androidbackup/data/DataBackup"
      ];

      backupConfig =
        let
          remotes = {
            local = {
              time = "18:00:00";
              path = "/srv/backups/";
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
          passwordFile = config.sops.secrets."hikari/restic_pw".path;
          rcloneConfigFile = config.sops.secrets.rclone_config.path;
          repository = remotes.${remote}.path + name;
          # backupPrepareCommand =
          #   # bash
          #   ''
          #     systemctl is-active --quiet wg-quick
          #     echo $? > /tmp/restore-proton-vpn
          #     ${pkgs.systemd}/bin/systemctl stop wg-quick-proton
          #   '';
          # backupCleanupCommand =
          #   # bash
          #   ''
          #     [[ $(< /tmp/restore-proton-vpn) -eq 0 ]] && ${pkgs.systemd}/bin/systemctl start wg-quick-proton
          #     rm -f /tmp/restore-proton-vpn
          #   '';
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
          exclude ? [
            ".*"
            "node_modules"
          ],
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
      paths = syncthingDirs;
      day = "Sat";
    })
    // (createBackups "media" {
      paths = mediaDirs;
      day = "Sun";
    })
    // (createBackups "git" {
      paths = gitRepos;
      day = "Mon";
      exclude = [
        "node_modules"
      ];
    })
    // (createBackups "android" {
      paths = androidBackup;
      day = "Tue";
    });

  systemd.services = lib.mkMerge (
    map (service: myLib.notifyOnServiceFailure ("restic-backups-" + service)) (
      builtins.attrNames config.services.restic.backups
    )
  );
}
