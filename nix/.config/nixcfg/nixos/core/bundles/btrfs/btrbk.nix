{ lib, config, ... }:

lib.mkIf config.me.enable.btrfs {
  services.btrbk.instances."home" = {
    onCalendar = "hourly";
    settings = {
      timestamp_format = "long";
      snapshot_preserve_min = "3d";
      snapshot_preserve = "7d";
      volume."/" = {
        snapshot_dir = "/snapshots";
        subvolume = "home";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /snapshots 0755 root root"
  ];
}
