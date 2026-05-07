{
  flake.nixos.pearlman =
    {
      pkgs,
      config,
      ...
    }:
    let
      stateDir = "/var/lib/seerr";
    in
    {
      me.services.seerr = {
        subdomain = "request";
        port = 5055;
      };

      virtualisation.oci-containers.containers.seerr =
        let
          name = "ghcr.io/seerr-team/seerr";
          version = "v3.2.0";
        in
        {
          image = name + ":" + version;

          imageFile = pkgs.dockerTools.pullImage {
            imageName = name;
            imageDigest = "sha256:c4cbd5121236ac2f70a843a0b920b68a27976be57917555f1c45b08a1e6b2aad";
            sha256 = "sha256-tvkQhcr05bqxPfmu9xaRatMkSPx2HZWWH1FMtrldkzw=";

            finalImageTag = version;
          };

          extraOptions =
            let
              inherit (config.users) users groups;
            in
            [
              "--init"
              "--user=${toString users.seerr.uid}:${toString groups.seerr.gid}"
            ];

          volumes = [
            "${stateDir}:/app/config"
          ];

          ports = [ "5055:5055" ];
        };

      users.users.seerr = {
        isSystemUser = true;
        group = "seerr";
        uid = 350;
      };

      users.groups.seerr.gid = 350;

      systemd.tmpfiles.settings.seer = {
        "${stateDir}".d = {
          group = "seerr";
          user = "seerr";
          mode = "0770";
        };
        "${stateDir}/cache".d = {
          group = "seerr";
          user = "seerr";
          mode = "0770";
        };
      };
    };
}
