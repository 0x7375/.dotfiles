{ inputs, ... }:

{
  flake.modules.nixos.woz =
    {
      lib,
      modulesPath,
      ...
    }:
    {

      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "usb_storage"
        "usbhid"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      hardware.asahi.peripheralFirmwareDirectory = inputs.asahi-firmware;

      boot.initrd.luks.devices.crypted = {
        device = "/dev/disk/by-uuid/d9e7427d-b109-46e2-925f-1498525506b2";
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };

      fileSystems."/" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = [
          "subvol=root"
          "compress=zstd"
          "noatime"
        ];
      };

      fileSystems."/home" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "compress=zstd"
          "noatime"
        ];
      };

      fileSystems."/nix" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = [
          "subvol=nix"
          "compress=zstd"
          "noatime"
        ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/4182-1A1E";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };

      fileSystems."/swap" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = [
          "subvol=@swap"
          "noatime"
        ];
      };

      swapDevices = [
        {
          device = "/swap/swapfile";
          size = 8192;
        }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
