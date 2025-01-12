{ pkgs, ... }:

{
  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/ajnart/homarr:latest";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/ajnart/homarr";
      imageDigest = "sha256:e4f51bc422be187c878082060eb720da7de64e5c650ea3fa86ab80981950decd";
      sha256 = "sha256-wJ7f+gnclTvPIqDgw8o2xmyI4Soj05RNd9Jh27kGTZ4=";
    };

    volumes = [
      "/var/lib/homarr/configs:/app/data/configs"
      "/var/lib/homarr/icons:/app/public/icons"
      "/var/lib/homarr/data:/data"
    ];

    ports = [ "7575:7575" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/homarr/configs 0770 root root -"
    "d /var/lib/homarr/icons 0770 root root -"
    "d /var/lib/homarr/data 0770 root root -"
  ];
}
