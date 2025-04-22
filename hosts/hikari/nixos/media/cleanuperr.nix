{
  secrets,
  lib,
  pkgs,
  config,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets.cleanuperr = {
    sopsFile = "${secrets}/cleanuperr.env";
    format = "dotenv";
    key = "";
  };

  virtualisation.oci-containers.containers.cleanuperr = {
    image = "ghcr.io/flmorg/cleanuperr:latest";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/flmorg/cleanuperr";
      imageDigest = "sha256:ea0358531eb50f40a6f9e420527c0642ee86ac08d0320879f3f069f91ed781af";
      sha256 = "xmoOG4IqmbtEsFI/5qA9fVLs3xXGs6OVpHPCTedUZcA=";

      finalImageTag = "latest";
    };

    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
    ];

    environmentFiles = [
      config.sops.secrets.cleanuperr.path
    ];

    environment = {
      TZ = config.time.timeZone;

      "QUEUECLEANER__IMPORT_FAILED_MAX_STRIKES" = "0";
      "QUEUECLEANER__IMPORT_FAILED_IGNORE_PATTERNS__0" = "title mismatch";
      "QUEUECLEANER__IMPORT_FAILED_IGNORE_PATTERNS__1" = "manual import required";

      "DOWNLOAD_CLIENT" = "qbittorrent";
      "QBITTORRENT__URL" = "http://host.docker.internal:8080";

      "DOWNLOADCLEANER__ENABLED" = "true";
      "DOWNLOADCLEANER__CATEGORIES__0__NAME" = "tv-sonarr";
      "DOWNLOADCLEANER__CATEGORIES__0__MAX_RATIO" = "2";
      "DOWNLOADCLEANER__CATEGORIES__1__NAME" = "radarr";
      "DOWNLOADCLEANER__CATEGORIES__1__MAX_RATIO" = "2";
    };
  };
}
