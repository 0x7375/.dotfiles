{
  secrets,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.me) hostname;
  mkHostSecret = lib.my.mkHostSecret hostname;
  syncthingRoot = "/data/syncthing";
in
lib.mkIf config.me.secrets.enable {
  packages = with pkgs; [
    rclone
    restic
  ];

  sops.secrets."restic_pw" = mkHostSecret "restic_pw" { };

  sops.secrets.rclone_config = {
    sopsFile = "${secrets}/${hostname}/rclone-config.ini";
    format = "ini";
  };

  vars.RESTIC_PASSWORD_FILE = config.sops.secrets."restic_pw".path;

  services.restic.backups =
    let
      syncthingDirs = map (path: "${syncthingRoot}/${path}") [
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
        (config.services.qbittorrent.profileDir + "/qBittorrent")
        config.services.radarr.dataDir
        config.services.sonarr.dataDir
        config.services.prowlarr.dataDir
        config.services.bazarr.dataDir
        "/var/lib/cleanuparr"
      ];

      gitRepos = [ "/data/git" ];

      backupConfig =
        let
          remotes = {
            local = {
              time = "18:00:00";
              path = "/data/backups/restic";
            };
            proton = {
              time = "20:00:00";
              path = "rclone:proton:";
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
        ".DS_Store"
        "desktop.ini"
        ".localized"
        "node_modules"
      ];
    });

  systemd.services = lib.mkMerge (
    map (service: lib.my.notifyOnServiceFailure ("restic-backups-" + service)) (
      builtins.attrNames config.services.restic.backups
    )
  );
}
