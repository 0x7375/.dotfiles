{ pkgs, ... }:

{
  services.prowlarr = {
    enable = true;
    package = pkgs.auto.prowlarr;
    openFirewall = true;
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "21hsmw/flaresolverr:nodriver";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "21hsmw/flaresolverr";
      imageDigest = "sha256:dca8cda5852b04e6142752fc044c9845eb536353ea6f8b7bb58b4ff9419538fa";
      sha256 = "sha256-Cifd9O+3Gi/ThzlQqbwJyK6FQYx5fGiFm/stJ0n1zQo=";

      finalImageTag = "nodriver";
    };

    ports = [ "8191:8191" ];
  };
}
