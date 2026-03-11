{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix
  ];

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
    options = [
      "nofail"
      "noatime"
      "commit=600"
    ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/dee864cb-6a3c-496f-a928-dc6bf3869ce1";
    fsType = "ext4";
    options = [
      "nofail"
      "noatime"
      "commit=600"
    ];
  };

  packages = [ pkgs.mergerfs ];

  fileSystems."/data" = {
    # device = "/mnt/ssd:/mnt/hdd";
    device = "/mnt/ssd";
    fsType = "fuse.mergerfs";
    options = [
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=epmfs"
      "fsname=mergerfs"
      "minfreespace=10G"
    ];
  };

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
    "rtsx_usb_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # disable UAS, use usb-storage
  boot.kernelParams = [ "usb-storage.quirks=0bda:9201:u" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
