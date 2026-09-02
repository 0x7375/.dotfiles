{ inputs, ... }:

{
  flake.modules.nixos.woz =
    {
      lib,
      config,
      pkgs,
      modulesPath,
      ...
    }:
    let
      # kernels are cross built from my desktop, they have to be in the cache to rebuild woz
      crossPkgs = import inputs.apple-silicon.inputs.nixpkgs {
        localSystem = "x86_64-linux";
        crossSystem = "aarch64-linux";
        overlays = [
          inputs.apple-silicon.overlays.default
          # (final: prev: {
          #   linux-asahi = prev.linux-asahi.override {
          #     extraMakeFlags = [ "-j20" ];
          #   };
          # })
        ];
      };

      systemCrossPkgs = import pkgs.path {
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

      boot.kernelPackages = lib.mkOverride 2 (
        # crossPkgs.linux-asahi.kernel.overrideAttrs (old: {
        #   makeFlags = (old.makeFlags or [ ]) ++ [ "-j20" ];
        # })
        (pkgs.linuxPackagesFor crossPkgs.linux-asahi.kernel).extend (
          _: _: {
            inherit (pkgs.linuxPackages) cpupower;
          }
        )
      );

      persist.directories = [
        "/root/.ssh"
      ];

      specialisation.fairydust.configuration =
        let
          fairyDustKernel = systemCrossPkgs.buildLinux {
            pname = "linux-asahi-fairydust";

            version = "7.0.11-fairydust";
            modDirVersion = "7.0.11";
            extraMeta.branch = "7.0.11";

            # extraMakeFlags = [ "-j20" ];

            src = systemCrossPkgs.fetchFromGitHub {
              owner = "AsahiLinux";
              repo = "linux";
              rev = "77e0fe0c47e847221988f6397167bc23fec2a042";
              hash = "sha256-wnNrbpa3dYceQU7ZeJ7eJH6k9QMqswctK/4xxGI9SZE=";
            };

            ignoreConfigErrors = true;

            kernelPatches = [
              {
                name = "Asahi config";
                patch = null;
                structuredExtraConfig = with systemCrossPkgs.lib.kernel; {
                  ARM64_16K_PAGES = yes;
                  ARM64_MEMORY_MODEL_CONTROL = yes;
                  ARM64_ACTLR_STATE = yes;
                  APPLE_WATCHDOG = yes;
                  APPLE_M1_CPU_PMU = yes;
                  HID_APPLE = module;
                  APPLE_PMGR_MISC = yes;
                  APPLE_PMGR_PWRSTATE = yes;
                  APPLE_MAILBOX = yes;
                  APPLE_RTKIT = yes;
                  APPLE_RTKIT_HELPER = yes;
                  RUST_FW_LOADER_ABSTRACTIONS = yes;
                };
                features.rust = true;
              }
            ];
          };
        in
        {
          system.nixos.tags = [ "fairydust" ];
          boot.kernelPackages = lib.mkOverride 1 (
            (pkgs.linuxPackagesFor fairyDustKernel).extend (
              _: _: {
                inherit (pkgs.linuxPackages) cpupower;
              }
            )
          );
        };

      # NOTE: for next build: override kernels to use 20 cores explicitely, maybe don't use the nixpkgs from the apple-silicon input to save a nixpkgs instance ig
      nix.buildMachines = [
        {
          hostName = "cray";
          systems = [ "x86_64-linux" ];
          protocol = "ssh-ng";

          maxJobs = 2;

          sshUser = config.me.user;
          sshKey = "/root/.ssh/nix_builder";
          supportedFeatures = [
            "benchmark"
            "big-parallel"
            "kvm"
            "nixos-test"
          ];
        }
      ];

      nix.distributedBuilds = true;

      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
