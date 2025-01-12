{ config, pkgs, ... }:

{
  users.groups.media = { };

  services.prowlarr = {
    enable = true;
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
    group = "media";
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.qBittorrent = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.jellyfin = {
    enable = true;
    package = pkgs.master.jellyfin;
    group = "media";
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    master.jellyfin-web
    jellyfin-ffmpeg
  ];
}
