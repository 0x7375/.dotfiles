{
  flake.modules.nixos.naitoh =
    {
      pkgs,
      config,
      ...
    }:
    let
      inherit (config.me.services.cleanuparr) port;
    in
    {
      me.services.cleanuparr = {
        subdomain = "cleanup";
        port = 11011;
        webSockets = true;
      };

      systemd.tmpfiles.settings.cleanuparr."/data/main/.state/cleanuparr".d = {
        group = "root";
        user = "root";
        mode = "0755";
      };

      networking.firewall.allowedTCPPorts = [ port ];

      virtualisation.oci-containers.containers.cleanuparr =
        let
          name = "ghcr.io/cleanuparr/cleanuparr";
          version = "2.10";
        in
        {
          image = name + ":" + version;

          imageFile = pkgs.dockerTools.pullImage {
            imageName = name;
            imageDigest = "sha256:9f74fa60bbf84c82b86f69fbef75189dd3e38408f99fd9c1895736185c4620b9";
            sha256 = "lkXBgq6WXg/zT5n7mbd3DHjhSShmz5EiBPg94hHw/1o=";

            finalImageTag = version;
          };

          extraOptions = [
            "--add-host=host.docker.internal:host-gateway"
          ];

          volumes = [
            "/data/main/.state/cleanuparr/:/config"
          ];

          ports = [ "${toString port}:${toString port}" ];

          environment = {
            TZ = toString config.time.timeZone;
            PUID = "0";
            PGID = "0";
          };
        };
    };
}
