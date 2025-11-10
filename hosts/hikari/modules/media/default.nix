{
  config,
  lib,
  ...
}:

{
  users.groups.${config.me.mediaGroup} = { };

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
}
