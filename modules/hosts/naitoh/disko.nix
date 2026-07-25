{ self, ... }:

{
  flake.modules.nixos.naitoh = { lib, ... }: {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HBHQ-000L2_S4DXNF0M702613";
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
          root = {
            size = "100%";
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

    disko.devices.disk.nvme = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-KBG5AZNT512G_LA_KIOXIA_82DPG3MSQBGK";
      content = {
        type = "gpt";
        partitions = {
          primary = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/mnt/nvme";
            };
          };
        };
      };
    };
  };
}
