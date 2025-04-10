{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  # sops key is inside home partition and needed
  # during boot: https://github.com/nix-community/disko/issues/192#issuecomment-2567944604
  fileSystems."/home".neededForBoot = true;
  virtualisation.vmVariantWithDisko = {
    virtualisation.fileSystems."/home".neededForBoot = true;
  };

  disko.devices = {
    disk.main = {
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
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "NIXROOT"
                ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"

                      # prevents decryption pw prompt to timeout: https://github.com/NixOS/nixpkgs/issues/250003
                      "x-systemd.device-timeout=0"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
