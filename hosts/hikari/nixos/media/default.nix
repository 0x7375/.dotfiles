{ lib, myLib, ... }:

{
  users.groups.${myLib.media-group} = { };

  systemd.services = lib.mkMerge (
    map (service: myLib.notifyOnServiceFailure service) [
      "podman-flaresolverr"
      "podman-cleanuparr"
      "jellyfin"
      "jellyseerr"
      "prowlarr"
      "qbittorrent"
      "radarr"
      "sonarr"
    ]
  );
}
