{ lib, config, ... }:

lib.mkIf config.me.enable.btrfs {
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };
}
