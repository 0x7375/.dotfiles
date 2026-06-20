{ self, ... }:

{
  flake.modules.nixos.cray = { lib, ... }: {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_250GB_S465NB0K933047Y";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
              extraArgs = [
                "-n"
                "NIXBOOT"
              ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              passwordFile = "/tmp/secret.key";
              extraOpenArgs = [ ];
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "NIXROOT"
                ];
                subvolumes = self.mkBtrfsSubvolumes {
                  inherit lib;
                  home = true;
                  swap = true;
                  swapSize = "16G";
                };
              };
            };
          };
        };
      };
    };
  };
}
