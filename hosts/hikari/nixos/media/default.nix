{ lib, myLib, ... }:

{
  users.groups.${myLib.media-group} = { };

  systemd.services = lib.mkMerge (
    map (service: myLib.notifyOnServiceFailure service) [
      "podman-flaresolverr"
      "jellyfin"
      "jellyseerr"
      "prowlarr"
      "qBittorrent"
      "radarr"
      "sonarr"
    ]
  );
}
