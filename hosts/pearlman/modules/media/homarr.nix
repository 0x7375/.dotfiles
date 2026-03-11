{
  secrets,
  config,
  pkgs,
  ...
}:

let
  stateDir = "/var/lib/homarr";
in
{
  boot.kernel.sysctl."vm.overcommit_memory" = 1;

  sops.secrets.homarr = {
    sopsFile = "${secrets}/pearlman/homarr.env";
    format = "dotenv";
    key = "";
  };

  virtualisation.oci-containers.containers.homarr =
    let
      name = "ghcr.io/homarr-labs/homarr";
      version = "v1.55.0";
    in
    {
      image = name + ":" + version;

      imageFile = pkgs.dockerTools.pullImage {
        imageName = name;
        imageDigest = "sha256:c29dfe8704593fce02c3e3d8efc74d3cfd9e3d4be63685093501e3122ed1f672";
        sha256 = "sha256-Wd+qfa6YbjexzCWur6HB/IxC/Jzx02pHiUlAeHk9QXM=";

        finalImageTag = version;
      };

      environment.BASE_URL = "https://home.0xaa.me";

      environmentFiles = [ config.sops.secrets.homarr.path ];

      volumes = [
        "${stateDir}/configs:/app/data/configs"
        "${stateDir}/icons:/app/public/icons"
        "${stateDir}/data:/data"
      ];

      ports = [ "7575:7575" ];
    };

  systemd.tmpfiles.settings.homarr =
    let
      dir = {
        group = "root";
        user = "root";
        mode = "0770";
      };
    in
    {
      "${stateDir}/configs".d = dir;
      "${stateDir}/icons".d = dir;
      "${stateDir}/data".d = dir;
    };
}
