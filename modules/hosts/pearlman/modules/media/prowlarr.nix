{
  flake.modules.nixos.pearlman =
    { config, pkgs, ... }:
    let
      inherit (config.me.services.byparr) port;
    in
    {
      me.services = {
        byparr = {
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

      virtualisation.oci-containers.containers.byparr =
        let
          name = "ghcr.io/thephaseless/byparr";
          version = "2.1";
        in
        {
          image = name + ":" + version;

          imageFile = pkgs.dockerTools.pullImage {
            imageName = name;
            imageDigest = "sha256:01a46a2865d9a6db5eb8ead04ec0dd33b8fbe233e8565ae70b50d4cc0af4cfb0";
            sha256 = "sha256-HZaScLUeNXODE+Q4q4YVzCUbL0F6pC0xzAIPXF+2hLE=";

            finalImageTag = version;
          };

          ports = [ "${toString port}:${toString port}" ];
        };
    };
}
