{ inputs, ... }:

{
  flake.modules.nixos.woz =
    {
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    let
      fairy-dust = pkgs.linux-asahi.kernel.overrideAttrs (old: rec {
        src = pkgs.fetchFromGitHub {
          owner = "AsahiLinux";
          repo = "linux";
          rev = "fairydust";
          hash = "sha256-wnNrbpa3dYceQU7ZeJ7eJH6k9QMqswctK/4xxGI9SZE=";
        };

        version = "7.0.11";
        modDirVersion = version;
      });
    in
    {

      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "usb_storage"
        "usbhid"
      ];

      # system.extraDependencies = [
      #   (pkgs.linuxPackagesFor fairy-dust.kernel)
      # ];
      # boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor fairy-dust);
      # boot.initrd.kernelModules = [ "typec_displayport" ];

      # force it to use the apple-silicon nixpkgs input otherwise cache doesn't work
      hardware.asahi.pkgs = lib.mkForce (
        import inputs.apple-silicon.inputs.nixpkgs {
          system = "aarch64-linux";
          overlays = [ inputs.apple-silicon.overlays.default ];
        }
      );

      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      # from https://github.com/nix-community/nixos-apple-silicon/issues/352
      # to persist volume level
      hardware.asahi.setupAsahiSound = true;
      services.pipewire.configPackages = lib.mkForce [ ];
      services.pipewire.wireplumber.configPackages = lib.mkForce [ ];
      packages = [ pkgs.asahi-audio ];

      hardware.asahi.peripheralFirmwareDirectory = inputs.asahi-firmware;

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
