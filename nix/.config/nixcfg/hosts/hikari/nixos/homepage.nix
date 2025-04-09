{ myLib, pkgs, ... }:

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

  systemd.services = (myLib.notifyOnServiceFailure "podman-homarr");

  # virtualisation.oci-containers.containers.mafl = {
  #   image = "ghcr.io/hywax/mafl:latest";
  #
  #   imageFile = pkgs.dockerTools.pullImage {
  #     imageName = "ghcr.io/hywax/mafl";
  #     imageDigest = "sha256:2c89020be334b341da41a6b95830b1b52b1b9f43c9f16d09c0ab4e9dad3ea4ad";
  #     sha256 = "sha256-vxJcUe367aFlTpSGN0TjBpZi9xTEC9KH1uNvbMg2BQw=";
  #   };
  #
  #   volumes = [
  #     "/var/lib/mafl:/app/data"
  #   ];
  #
  #   ports = [ "7575:3000" ];
  # };
  #
  # systemd.tmpfiles.rules =
  #   let
  #     content =
  #       builtins.replaceStrings [ "\n" ] [ "\\n" ]
  #         # yaml
  #         ''
  #           title: Homepage
  #           services:
  #             Torrent:
  #               - title: qBittorrent
  #                 description: Torrent client
  #                 link: https://torrent.shimu.duckdns.org
  #                 icon:
  #                   url: https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/New_qBittorrent_Logo.svg/1024px-New_qBittorrent_Logo.svg.png
  #                   wrap: true
  #                 status:
  #                   enabled: true
  #         '';
  #   in
  #   [
  #     "d /var/lib/mafl 0770 root root -"
  #     "f+ /var/lib/mafl/config.yml 0660 root root - ${content}"
  #   ];
  #
  # systemd.services = (myLib.notifyOnServiceFailure "podman-mafl");
}
