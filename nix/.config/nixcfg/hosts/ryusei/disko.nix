{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
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
                name = "cryptlvm";
                passwordFile = "/tmp/secret.key";
                extraOpenArgs = [ ];
                settings = {
                  allowDiscards = true;
                  preLVM = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "vg";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      vg = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "16G";
            content = {
              type = "swap";
              extraArgs = [ "-L NIXSWAP" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
                "noatime"
                "nodiratime"
                "discard"

                # prevents decryption pw prompt to timeout: https://github.com/NixOS/nixpkgs/issues/250003
                "x-systemd.device-timeout=0"
              ];
              extraArgs = [ "-L NIXROOT" ];
            };
          };
        };
      };
    };
  };
}
