{ config, pkgs, ... }:

let
  inherit (config.me.services.flaresolverr) port;
in
{
  me = {
    flaresolverr = {
      subdomain = "solver";
      port = 8191;
    };
    prowlarr = {
      subdomain = "indexer";
      port = 9696;
    };
  };

  services.prowlarr = {
    enable = true;
    package = pkgs.auto.prowlarr;
    openFirewall = true;
  };

  virtualisation.oci-containers.containers.flaresolverr =
    let
      name = "21hsmw/flaresolverr";
      version = "nodriver";
    in
    {
      image = name + ":" + version;

      imageFile = pkgs.dockerTools.pullImage {
        imageName = name;
        imageDigest = "sha256:8462a7dc8ca7dcc4113375bcfece02643627c6a4a5d0ad6215e9472668c34794";
        sha256 = "sha256-2XkRR2+6XTJnpG3TFMi3lfGkpn1292GRXiTMO6dNId8=";

        finalImageTag = version;
      };

      ports = [ "${toString port}:${toString port}" ];
    };
}
