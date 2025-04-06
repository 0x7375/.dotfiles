{
  myLib,
  lib,
  config,
  pkgs,
  ...
}:

let
  group = "media";
  ntfyPort = 8719;
in
{
  users.groups.media = { };

  services.prowlarr = {
    enable = true;
    package = pkgs.media.prowlarr;
    openFirewall = true;
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "flaresolverr/flaresolverr:v3.3.21";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "flaresolverr/flaresolverr";
      imageDigest = "sha256:f104ee51e5124d83cf3be9b37480649355d223f7d8f9e453d0d5ef06c6e3b31b";
      sha256 = "sha256-N5NY89albL7Kws9pBRoDtW3Ae2vIKH1k1+9nVQJ3ltU=";

      finalImageTag = "v3.3.21";
    };

    ports = [ "8191:8191" ];

    environment.TZ = config.time.timeZone;
  };

  services.radarr = {
    enable = true;
    inherit group;
    package = pkgs.media.radarr;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    inherit group;
    package = pkgs.media.sonarr;
    openFirewall = true;
  };

  services.qBittorrent = {
    enable = true;
    inherit group;
    package = pkgs.media.qbittorrent-nox;
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    package = pkgs.media.jellyseerr;
    configDir = "/var/lib/jellyseerr";
  };

  services.jellyfin = {
    enable = true;
    package = pkgs.media.jellyfin;
    inherit group;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    media.jellyfin-web
    media.jellyfin-ffmpeg
  ];

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "http://localhost:" + toString ntfyPort;
      listen-http = ":" + toString ntfyPort;
      auth-default-access = "read-write";

    };
  };
  networking.firewall.allowedTCPPorts = [ ntfyPort ];

  systemd.services = lib.mkMerge (
    map (service: myLib.notifyOnServiceFailure service) [
      "podman-homarr"
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
