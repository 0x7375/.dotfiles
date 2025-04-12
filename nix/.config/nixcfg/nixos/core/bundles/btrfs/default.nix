{ lib, config, ... }:

lib.mkIf config.me.btrfs.enable {
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };
}
