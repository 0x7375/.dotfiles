{ self, ... }:

{
  flake.nixos.pearlman =
    {
      config,
      lib,
      ...
    }:
    {
      options.me.mediaGroup = lib.mkOption {
        type = lib.types.str;
        default = "media";
        description = "Media group name";
        internal = true;
      };

      config = {
        systemd.tmpfiles.settings."arr-media" =
          let
            mkDir = user: {
              inherit user;
              group = "media";
              mode = "0775";
            };

            mkMediaDirs = base: {
              "${base}/media".d = mkDir "root";
              "${base}/media/movies".d = mkDir "radarr";
              "${base}/media/shows".d = mkDir "shows";
              "${base}/torrents".d = mkDir "qbittorrent";
              "${base}/torrents/radarr".d = mkDir "qbittorrent";
              "${base}/torrents/tv-sonarr".d = mkDir "qbittorrent";
            };
          in
          mkMediaDirs "/mnt/ssd" // mkMediaDirs "/mnt/hdd";

        users.groups.${config.me.mediaGroup}.gid = 989;

        systemd.services = lib.mkMerge (
          map (service: self.lib.notifyOnServiceFailure service) [
            "podman-byparr"
            "podman-cleanuparr"
            "podman-seerr"
            "jellyfin"
            "syncthing"
            # "jellyseerr"
            "prowlarr"
            "qbittorrent"
            "radarr"
            "sonarr"
          ]
        );
      };
    };
}
