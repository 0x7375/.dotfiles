{
  flake.modules.nixos.btrfs =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages = [ pkgs.btdu ];

      aliases.btdu = "sudo mkdir -p /mnt/crypted; sudo mount -o subvol=/ /dev/mapper/crypted /mnt/crypted && sudo ${lib.getExe pkgs.btdu} /mnt/crypted && sudo umount -l /mnt/crypted";

      services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/" ];
      };

      services.btrbk.instances."persist" = {
        onCalendar = "hourly";
        settings = {
          timestamp_format = "long";
          snapshot_preserve_min = "3d";
          snapshot_preserve = "7d";
          volume."/persist" = {
            snapshot_dir = "/snapshots";
            subvolume = ".";
          };
        };
      };
    };
}
