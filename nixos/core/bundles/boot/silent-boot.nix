{ lib, config, ... }:

lib.mkIf config.me.boot.silent.enable {
  boot.kernelParams = [
    "quiet"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  boot.consoleLogLevel = lib.mkForce 0; # forcing because disko sets this
  boot.initrd.verbose = false;
}
