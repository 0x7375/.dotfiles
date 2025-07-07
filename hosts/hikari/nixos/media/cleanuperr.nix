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

  systemd.tmpfiles.rules = [
    "d /var/lib/cleanuperr 0755 root root -"
    "d /var/lib/cleanuperr/logs 0755 root root -"
  ];

  virtualisation.oci-containers.containers.cleanuperr = {
    image = "ghcr.io/flmorg/cleanuperr:latest";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/flmorg/cleanuperr";
      imageDigest = "sha256:ea0358531eb50f40a6f9e420527c0642ee86ac08d0320879f3f069f91ed781af";
      sha256 = "xmoOG4IqmbtEsFI/5qA9fVLs3xXGs6OVpHPCTedUZcA=";

      finalImageTag = "latest";
    };

    # volumes = [
    #   "/var/lib/cleanuperr/logs:/var/logs"
    # ];

    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
    ];

    environmentFiles = [
      config.sops.secrets.cleanuperr.path
    ];

    environment = {
      # 1 strike happens every 5 minutes

      TZ = config.time.timeZone;

      "LOGGING__LOGLEVEL" = "Verbose";
      # "LOGGING__FILE__ENABLED" = "false";
      # "LOGGING__FILE__PATH" = "/var/log/";

      "QUEUECLEANER__IMPORT_FAILED_MAX_STRIKES" = "3";
      "QUEUECLEANER__IMPORT_FAILED_IGNORE_PATTERNS__0" = "title mismatch";
      "QUEUECLEANER__IMPORT_FAILED_IGNORE_PATTERNS__1" = "manual import required";

      # 3 hours
      "QUEUECLEANER__STALLED_MAX_STRIKES" = "36";
      "QUEUECLEANER__STALLED_RESET_STRIKES_ON_PROGRESS" = "true";

      "QUEUECLEANER__DOWNLOADING_METADATA_MAX_STRIKES" = "3";

      # "QUEUECLEANER__SLOW_MAX_STRIKES" = "3";
      # "QUEUECLEANER__SLOW_MAX_TIME" = "168";
      # "QUEUECLEANER__SLOW_RESET_STRIKES_ON_PROGRESS" = "true";

      "DOWNLOAD_CLIENT" = "qbittorrent";
      "QBITTORRENT__URL" = "http://host.docker.internal:8080";

      "DOWNLOADCLEANER__ENABLED" = "true";
      "DOWNLOADCLEANER__CATEGORIES__0__NAME" = "tv-sonarr";
      "DOWNLOADCLEANER__CATEGORIES__0__MAX_RATIO" = "2.0";
      "DOWNLOADCLEANER__CATEGORIES__1__NAME" = "radarr";
      "DOWNLOADCLEANER__CATEGORIES__1__MAX_RATIO" = "2.0";

      "SONARR__ENABLED" = "true";
      "SONARR__INSTANCES__0__URL" = "http://host.docker.internal:8989";
      "RADARR__ENABLED" = "true";
      "RADARR__INSTANCES__0__URL" = "http://host.docker.internal:7878";
    };
  };
}
