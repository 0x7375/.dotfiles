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
        ".local/state/zsh"
      ];

      mediaDirs = [
        config.services.jellyseerr.configDir
        config.services.jellyfin.dataDir
        config.services.qBittorrent.dataDir
        config.services.radarr.dataDir
        config.services.sonarr.dataDir
        "/var/lib/prowlarr"
        "/var/lib/homarr"
      ];

      backupConfig =
        let
          remotes = {
            local = {
              time = "18:00:00";
              path = "/srv/backups/";
            };
            koofr = {
              time = "20:00:00";
              path = "rclone:koofr:";
            };
            google = {
              time = "22:00:00";
              path = "rclone:google:";
            };
          };
        in
        {
          remote,
          day,
          paths,
          name,
        }:
        {
          initialize = true;
          passwordFile = config.sops.secrets."hikari/restic_pw".path;
          rcloneConfigFile = config.sops.secrets.rclone_config.path;
          repository = remotes.${remote}.path + name;
          inherit paths;
          exclude = [
            ".*"
            "node_modules"
          ];
          timerConfig = {
            OnCalendar = day + " *-*-* " + remotes.${remote}.time;
            Persistent = true;
          };
        };

      createBackups =
        name:
        { paths, day }:
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
                  ;
              };
            })
            [
              "local"
              "koofr"
              "google"
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
    });

  systemd.services = lib.mkMerge (
    map (service: myLib.notifyOnServiceFailure ("restic-backups-" + service)) (
      builtins.attrNames config.services.restic.backups
    )
  );
}
