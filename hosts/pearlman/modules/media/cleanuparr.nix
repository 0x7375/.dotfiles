{
  pkgs,
  config,
  ...
}:

let
  inherit (config.me.services.cleanuparr) port;
in
{
  systemd.tmpfiles.settings.cleanuparr."/var/lib/cleanuparr".d = {
    group = "root";
    user = "root";
    mode = "0755";
  };

  networking.firewall.allowedTCPPorts = [ port ];

  virtualisation.oci-containers.containers.cleanuparr =
    let
      name = "ghcr.io/cleanuparr/cleanuparr";
      version = "2.7.7";
    in
    {
      image = name + ":" + version;

      imageFile = pkgs.dockerTools.pullImage {
        imageName = name;
        imageDigest = "sha256:834072365f22211aa8f25103b7896f566641e2f5ccc50bb9050afd0696f4cade";
        sha256 = "ckoUNy8BYHNr57T4CQNOLa2myjEfDk3O/3l2S8b0b4A=";

        finalImageTag = version;
      };

      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];

      volumes = [
        "/var/lib/cleanuparr/:/config"
      ];

      ports = [ "${toString port}:${toString port}" ];

      environment = {
        TZ = toString config.time.timeZone;
        PUID = "0";
        PGID = "0";
      };
    };
}
