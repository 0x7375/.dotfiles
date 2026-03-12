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
          user = user;
          group = "media";
          mode = "0755";
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
      map (service: lib.my.notifyOnServiceFailure service) [
        "podman-flaresolverr"
        "podman-cleanuparr"
        "jellyfin"
        # "jellyseerr"
        "prowlarr"
        "qbittorrent"
        "radarr"
        "sonarr"
      ]
    );
  };
}
