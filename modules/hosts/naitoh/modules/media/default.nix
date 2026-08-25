{ self, ... }:

{
  flake.modules.nixos.naitoh =
    { pkgs, lib, ... }:
    {
      options.me.mediaGroup = lib.mkOption {
        type = lib.types.str;
        default = "media";
        description = "Media group name";
        internal = true;
      };

      config = {
        services.recyclarr.package = pkgs.auto.recyclarr;

        nixflix = {
          enable = true;
          mediaDir = "/data/shared/media";
          downloadsDir = "/data/shared/downloads";
          stateDir = "/data/main/.state";
          postgres.enable = true;
          recyclarr.enable = true;
        };

        systemd.tmpfiles.settings."arr-media" =
          let
            mkDir = user: {
              inherit user;
              group = "media";
              mode = "02775";
            };

            mkMediaDirs = base: {
              "${base}/media".d = mkDir "root";
              "${base}/media/movies".d = mkDir "radarr";
              "${base}/media/tv".d = mkDir "sonarr";
              "${base}/downloads/torrent".d = mkDir "qbittorrent";
              "${base}/downloads/torrent/default".d = mkDir "qbittorrent";
              "${base}/downloads/torrent/prowlarr".d = mkDir "qbittorrent";
              "${base}/downloads/torrent/radarr".d = mkDir "qbittorrent";
              "${base}/downloads/torrent/sonarr".d = mkDir "qbittorrent";
            };
          in
          mkMediaDirs "/mnt/ssd" // mkMediaDirs "/mnt/hdd" // mkMediaDirs "/mnt/nvme";

        systemd.services = lib.mkMerge (
          map (service: self.lib.notifyOnServiceFailure service) [
            "podman-cleanuparr"
            "jellyfin"
            "syncthing"
            "seerr"
            "prowlarr"
            "flaresolverr"
            "qbittorrent"
            "qui"
            "radarr"
            "sonarr"
            "bazarr"
            "recylarr"
            "attic"
            "sshd"
            "beszel-agent"
            "beszel-hub"
          ]
        );
      };
    };
}
