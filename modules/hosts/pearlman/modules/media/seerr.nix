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
          version = "v3.1.0";
        in
        {
          image = name + ":" + version;

          imageFile = pkgs.dockerTools.pullImage {
            imageName = name;
            imageDigest = "sha256:b35ba0461c4a1033d117ac1e5968fd4cbe777899e4cbfbdeaf3d10a42a0eb7e9";
            sha256 = "sha256-tutrSb/qrDNlhPZFXrV/lNoNYKP6vZlZ0oGvtQuzwt4=";

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
