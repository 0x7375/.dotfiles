{ self, ... }:

{
  flake.modules.nixos.woz = { lib, ... }: {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-uuid/d9e7427d-b109-46e2-925f-1498525506b2";
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
          subvolumes = self.lib.mkBtrfsSubvolumes {
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
