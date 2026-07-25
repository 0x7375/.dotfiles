{
  flake.lib.mkBtrfsSubvolumes =
    let
      mountOptions = [
        "noatime"
        "compress=zstd"
      ];
    in
    {
      lib,
      home ? true,
      swap ? false,
      swapSize ? "8G",
    }:
    {
      "@blank" = { };
      "@root" = {
        mountpoint = "/";
        inherit mountOptions;
      };
      "@log" = {
        mountpoint = "/var/log";
        inherit mountOptions;
      };
      "@nix" = {
        mountpoint = "/nix";
        inherit mountOptions;
      };
      "@persist" = {
        mountpoint = "/persist";
        inherit mountOptions;
      };
      "@snapshots" = {
        mountpoint = "/snapshots";
        inherit mountOptions;
      };
    }
    // lib.optionalAttrs home {
      "@home" = {
        mountpoint = "/home";
        inherit mountOptions;
      };
    }
    // lib.optionalAttrs swap {
      "@swap" = {
        mountpoint = "/swap/swapfile";
        swap.swapfile.size = swapSize;
      };
    };

  flake.modules.nixos.core =
    { lib, config, ... }:
    {
      imports = [
        (lib.mkAliasOptionModule [ "persist" ] [ "preservation" "preserveAt" "/persist" ])
        (lib.mkAliasOptionModule
          [ "persistUser" ]
          [ "preservation" "preserveAt" "/persist" "users" config.me.user ]
        )
      ];
    };

  flake.modules.nixos.preservation =
    { pkgs, config, ... }:
    {
      preservation.enable = true;

      persist = {
        directories = [
          "/var/lib/systemd"
          "/mnt"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
      };

      systemd.tmpfiles.rules = [
        "d ${config.me.home} 0700 ${config.me.user} users - -"
      ];

      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

      nixpkgs.overlays = [
        (final: prev: {
          my = (prev.my or { }) // {
            fs-diff = import ./_fs-diff.nix pkgs;
          };
        })
      ];

      packages = [ pkgs.my.fs-diff ];

      persistUser = {
        directories = [
          {
            directory = ".config";
            how = "_intermediate";
          }
          {
            directory = ".cache";
            how = "_intermediate";
          }
          {
            directory = ".local";
            how = "_intermediate";
          }
          {
            directory = ".local/share";
            how = "_intermediate";
          }
          {
            directory = ".local/state";
            how = "_intermediate";
          }
        ];
      };

      # https://notashelf.dev/posts/impermanence
      boot.initrd.systemd = {
        enable = true;
        services.rollback = {
          description = "Rollback BTRFS root subvolume to a pristine state";
          wantedBy = [ "initrd.target" ];
          after = [ "systemd-cryptsetup@crypted.service" ];
          before = [ "sysroot.mount" ];

          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt

            mount -o subvol=/ /dev/mapper/crypted /mnt

            btrfs subvolume list -o /mnt/@root |
              cut -f9 -d' ' |
              while read subvolume; do
                echo "deleting /$subvolume subvolume..."
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "deleting @root subvolume..." &&
              btrfs subvolume delete /mnt/@root &&
              echo "deleting @home subvolume..." &&
              btrfs subvolume delete /mnt/@home

            echo "restoring blank root subvolume..."
            btrfs subvolume snapshot /mnt/@blank /mnt/@root
            echo "restoring blank @home subvolume..."
            btrfs subvolume snapshot /mnt/@blank /mnt/@home

            umount /mnt
          '';
        };
      };

      sops.age.sshKeyPaths = pkgs.lib.optionals (!config.me.tpm.enable) [
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ];

      fileSystems."/var/log".neededForBoot = true;
      fileSystems."/persist".neededForBoot = true;
    };
}
