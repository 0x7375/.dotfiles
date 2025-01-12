{ lib, config, ... }:

lib.mkIf config.me.boot.enable {
  boot.kernelParams = [
    "quiet"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  boot.consoleLogLevel = lib.mkForce 0; # forcing because disko sets this
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;
  systemd.watchdog.rebootTime = "0";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 30;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
}
