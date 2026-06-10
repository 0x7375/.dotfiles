{
  flake.modules.nixos.core = { lib, config, ... }: {
    imports = [
      (lib.mkAliasOptionModule [ "persist" ] [ "preservation" "preserveAt" "/persist" ])
      (lib.mkAliasOptionModule
        [ "persistUser" ]
        [ "preservation" "preserveAt" "/persist" "users" config.me.user ]
      )
    ];
  };

  flake.modules.nixos.preservation = {

    preservation.enable = true;

    persist = {
      directories = [
        "/var/lib/systemd/timers"
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
        ".cache/mesa_shader_cache"
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

          btrfs subvolume list -o /mnt/root |
            cut -f9 -d' ' |
            while read subvolume; do
              btrfs subvolume delete "/mnt/$subvolume"
            done &&
            btrfs subvolume delete /mnt/root
            btrfs subvolume delete /mnt/@home

          btrfs subvolume snapshot /mnt/@blank /mnt/root
          btrfs subvolume snapshot /mnt/@blank /mnt/@home

          umount /mnt
        '';
      };
    };
  };
}
