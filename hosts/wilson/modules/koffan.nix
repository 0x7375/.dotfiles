{ pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/koffan 0755 root root -"
  ];


  networking.firewall.allowedTCPPorts = [ 3000 ];

  virtualisation.oci-containers.containers.koffan =
    let
      name = "ghcr.io/pansalut/koffan";
      version = "v1.9.2";
    in
    {
      image = name + ":" + version;

      imageFile = pkgs.dockerTools.pullImage {
        imageName = name;
        imageDigest = "sha256:05144c8b3ca7021e53f2889b4284f9d1083d122b3dfa42b5614050c00a7e5e71";
        sha256 = "sha256-LnmjKpNinQ9qb/gwOkdHwwXTPKwTTujdIP+VAwMOqsk=";

        finalImageTag = version;
      };
      ports = [ "3000:80" ];

      environment = {
        APP_ENV = "production";
        DISABLE_AUTH = "true";
        DEFAULT_LANG = "fr";
      };

      volumes = [
        "/var/lib/koffan:/data"
      ];
    };
}
