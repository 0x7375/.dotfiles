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
  };
}
