{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix
  ];

  boot.blacklistedKernelModules = [ "pcspkr" ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "aesni_intel"
    "cryptd"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # non-declarative config

  # boot.resumeDevice = "/dev/disk/by-label/NIXSWAP";

  # boot.initrd.luks.devices."cryptlvm" = {
  #   device = "/dev/disk/by-label/NIXLUKS";
  #   allowDiscards = true;
  #   preLVM = true;
  # };

  # fileSystems."/" = {
  #   device = "/dev/disk/by-label/NIXROOT";
  #   fsType = "ext4";
  #   options = [
  #     "noatime"
  #     "nodiratime"
  #     "discard"
  #
  #     # prevents decryption pw prompt to timeout: https://github.com/NixOS/nixpkgs/issues/250003
  #     "x-systemd.device-timeout=0"
  #   ];
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-label/NIXBOOT";
  #   fsType = "vfat";
  # };

  # swapDevices = [
  #   { device = "/dev/disk/by-label/NIXSWAP"; }
  # ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
