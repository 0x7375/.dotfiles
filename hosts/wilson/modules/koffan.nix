{ pkgs, ... }:

{
  virtualisation.oci-containers.containers.koffan =
    let
      name = "ghcr.io/pansalut/koffan";
      version = "v1.9.2";
    in
    {
      image = name + ":" + version;

      imageFile = pkgs.dockerTools.pullImage {
        imageName = name;
        imageDigest = "sha256:05144c8b3ca7021e53f2889b4284f9d1083d122b3dfa42b5614050c00a7e5e71 ";
        sha256 = "9gBFwphlLnmKmKFCb2+U+YM+dWeBr9k+60+y96E85+U=";

        finalImageTag = version;
      };
      ports = [ "3000:80" ];

      environment = {
        APP_ENV = "production";
        DISABLE_AUTH = true;
        DEFAULT_LANG = "fr";
      };

      volumes = [
        "/var/lib/koffan:/data"
      ];
    };
}
