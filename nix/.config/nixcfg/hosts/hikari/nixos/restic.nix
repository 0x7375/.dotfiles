{
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
      backupConfig = repo: calendar: {
        initialize = true;
        passwordFile = config.sops.secrets."hikari/restic_pw".path;
        rcloneConfigFile = config.sops.secrets.rclone_config.path;
        repository = repo;
        paths = map (path: "/home/${config.me.user}/${path}") [
          "documents"
          "games/ds"
          "perso"
          "photos"
          "pictures"
          "uni"
          "notes"
        ];
        exclude = [
          ".*"
        ];
        timerConfig = {
          OnCalendar = calendar;
          Persistent = true;
        };
      };
    in
    {
      local-syncthing = backupConfig "/srv/backups/syncthing" "Sat *-*-* 18:00:00";
      koofr-syncthing = backupConfig "rclone:koofr:syncthing" "Sat *-*-* 20:00:00";
      google-syncthing = backupConfig "rclone:google:syncthing" "Sat *-*-* 22:00:00";
    };
}
