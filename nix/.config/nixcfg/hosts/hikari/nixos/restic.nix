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

  age.secrets.rclone = {
    file = "${secrets}/rclone.age";
  };

  age.secrets.restic = {
    file = "${secrets}/restic.age";
  };

  services.restic.backups =
    let
      backupConfig = repo: calendar: {
        initialize = true;
        passwordFile = config.age.secrets.restic.path;
        rcloneConfigFile = config.age.secrets.rclone.path;
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
      mega-syncthing = backupConfig "rclone:mega:syncthing" "Sat *-*-* 20:00:00";
      proton-syncthing = backupConfig "rclone:proton:syncthing" "Sat *-*-* 22:00:00";
    };
}
