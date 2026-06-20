{ self, ... }:

{
  flake.modules.woz = { lib, ... }: {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/nvme0n1p5";
      content = {
        type = "luks";
        name = "crypted";
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
            swapSize = "8G";
          };
        };
      };
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/4182-1A1E";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
