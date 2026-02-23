{
  pkgs,
  config,
  ...
}:

let
  inherit (config.me.services.cleanuparr) port;
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/cleanuparr 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [ port ];

  virtualisation.oci-containers.containers.cleanuparr =
    let
      name = "ghcr.io/cleanuparr/cleanuparr";
      version = "2.5.1";
    in
    {
      image = name + ":" + version;

      imageFile = pkgs.dockerTools.pullImage {
        imageName = name;
        imageDigest = "sha256:47bb76b03676d5b9bb3c7a01f1a9005066d60db63b3f8379057d77f89daa6c37";
        sha256 = "3LYiHhc9pKBqdFvStore9ZuYFVm+xxH5pHF437VWEE4=";

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
