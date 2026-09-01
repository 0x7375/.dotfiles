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
      # kernels are cross built from my desktop, they have to be in the cache to rebuild woz
      crossPkgs = import inputs.apple-silicon.inputs.nixpkgs {
        localSystem = "x86_64-linux";
        crossSystem = "aarch64-linux";
        overlays = [ inputs.apple-silicon.overlays.default ];
      };
    in
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "usb_storage"
        "usbhid"
      ];

      nixpkgs.overlays = [
        (final: prev: {
          # silent uboot
          uboot-asahi = prev.uboot-asahi.overrideAttrs (old: {
            postPatch =
              (old.postPatch or "")
              +
              # bash
              ''
                cat >> configs/${old.defconfig} <<'EOF'
                CONFIG_SILENT_CONSOLE=y
                CONFIG_BOOTDELAY=1
                EOF
                # force silent
                sed -i '/static bool console_update_silent(void)/,/^}/ s/^{/{\n\tgd->flags |= GD_FLG_SILENT;\n\treturn false;/' common/console.c

                # suppress the uboot version info line
                sed -i '/^int console_announce_r(void)/,/^}/ s/^{/{\n\tif (gd->flags \& GD_FLG_SILENT)\n\t\treturn 0;/' common/console.c

                # suppress uboot image
                sed -i 's/ret = show_splash(dev);/ret = 0;/g' drivers/video/video-uclass.c
              '';
          });
        })
      ];

      hardware.asahi = {
        enable = true;
        peripheralFirmwareDirectory = inputs.asahi-firmware;
      };

      boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor crossPkgs.linux-asahi.kernel);

      specialisation.fairydust.configuration =
        let
          fairyDustKernel = crossPkgs.buildLinux {
            pname = "linux-asahi-fairydust";
            version = "7.1.9-fairydust";
            modDirVersion = "7.1.9";
            extraMeta.branch = "fairydust";
            src = crossPkgs.fetchFromGitHub {
              owner = "AsahiLinux";
              repo = "linux";
              rev = "96775a0e72995e79e13b93755d456cb128dcdc81";
              hash = "sha256-3WoZ33v0mrb/cesfGPVzl8QEYLS1ASecPb+OEhpc7q0=";
            };
            kernelPatches = [
              {
                name = "Asahi config";
                patch = null;
                structuredExtraConfig = with crossPkgs.lib.kernel; {
                  ARM64_16K_PAGES = yes;
                  ARM64_MEMORY_MODEL_CONTROL = yes;
                  ARM64_ACTLR_STATE = yes;
                  APPLE_WATCHDOG = yes;
                  APPLE_M1_CPU_PMU = yes;
                  HID_APPLE = module;
                  APPLE_PMGR_MISC = yes;
                  APPLE_PMGR_PWRSTATE = yes;
                };
                features.rust = true;
              }
            ];
          };
        in
        {
          system.nixos.tags = [ "fairydust" ];
          boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor fairyDustKernel);
        };

      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
