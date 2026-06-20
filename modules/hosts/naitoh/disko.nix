{ self, ... }:

{
  flake.modules.nixos.naitoh = { lib, ... }: {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
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
                subvolumes = self.lib.mkBtrfsSubvolumes {
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
