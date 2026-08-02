{
  flake.modules.nixos.btrfs =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      packages = [ pkgs.btdu ];

      aliases.btdu =
        let
          mountDir = "/mnt/btrfs";
        in
        "sudo mkdir -p ${mountDir}; sudo mount -o subvol=/ ${config.fileSystems."/".device} ${mountDir} && sudo ${lib.getExe pkgs.btdu} ${mountDir} && sudo umount -l ${mountDir}";

      services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/" ];
      };

      services.btrbk.instances.persist = {
        onCalendar = "hourly";
        settings = {
          timestamp_format = "long";
          snapshot_preserve_min = "3d";
          snapshot_preserve = "7d";
          volume."/persist" = {
            snapshot_dir = "/snapshots";
            subvolume = ".";
          };
        };
      };

      systemd.services.btrfs-balance = {
        description = "Btrfs metadata balance";
        script = ''
          ${lib.getExe pkgs.btrfs-progs} balance start -musage=20 / || true
        '';
        serviceConfig.Type = "oneshot";
      };

      systemd.timers.btrfs-balance = {
        description = "Weekly btrfs balance";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
}
