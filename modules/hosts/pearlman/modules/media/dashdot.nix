{
  flake.nixos.pearlman =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.me.services.dashdot) port;
    in
    {
      me.services.dashdot = {
        subdomain = "dash";
        port = 3001;
      };

      virtualisation.oci-containers.containers.dashdot =
        let
          name = "ghcr.io/mauricenino/dashdot";
          version = "6.3.4";
        in
        {
          image = name + ":" + version;

          imageFile = pkgs.dockerTools.pullImage {
            imageName = name;
            imageDigest = "sha256:434a54d2937411a06b09c50e55709cc7d3b092c0fe173a9e5c986f9b5a33c7c6";
            sha256 = "sha256-RbrBJszCP96piSED4vy5/JTocrLRnwJbU/0vOm+9e3k=";

            finalImageTag = version;
          };

          ports = [ "${toString port}:${toString port}" ];

          volumes = [ "/:/mnt/host:ro" ];

          extraOptions = [ "--privileged=true" ];

          environment = {
            DASHDOT_PAGE_TITLE = "Dashboard";
            DASHDOT_USE_IMPERIAL = "false";
            DASHDOT_ALWAYS_SHOW_PERCENTAGES = "true";
            DASHDOT_OVERRIDE_OS = "NixOS";
            DASHDOT_OVERRIDE_ARCH = config.nixpkgs.hostPlatform.system;

            DASHDOT_ACCEPT_OOKLA_EULA = "true";

            # first column of `df` output to get this name
            DASHDOT_FS_VIRTUAL_MOUNTS = "mergerfs";
            # un-ignore fuse.mergerfs filesystem type
            DASHDOT_FS_TYPE_FILTER = "cifs,9p,fuse.rclone,nfs4,iso9660,fuse.shfs,autofs";

            DASHDOT_FS_DEVICE_FILTER = "mmcblk0boot0,mmcblk0boot1,mmcblk1boot0,mmcblk1boot1";
          };
        };
    };
}
