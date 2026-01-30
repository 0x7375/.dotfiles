{
  pkgs,
  config,
  ...
}:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/cleanuparr 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [ 11011 ];

  virtualisation.oci-containers.containers.cleanuparr = {
    image = "ghcr.io/cleanuparr/cleanuparr:2.0.14";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/cleanuparr/cleanuparr";
      imageDigest = "sha256:7b45aca162cab47fc228b7e1866930d5a85660378cd796f378075ade786863aa";
      sha256 = "bMyc43CHD9jqxc21/vGshj9jPe1ALMgHNRNNkMlnGo0=";

      finalImageTag = "2.0.14";
    };

    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
    ];

    volumes = [
      "/var/lib/cleanuparr/:/config"
    ];

    ports = [ "11011:11011" ];

    environment = {
      TZ = toString config.time.timeZone;
      PUID = "0";
      PGID = "0";
    };
  };
}
