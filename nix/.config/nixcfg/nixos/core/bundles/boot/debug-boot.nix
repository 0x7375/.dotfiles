{ lib, config, ... }:

lib.mkIf config.me.boot.debug.enable {
  boot.plymouth.enable = lib.mkForce false;

  boot.kernelParams = [
    "systemd.show_status=true"
    "systemd.log_level=debug"
    "systemd.log_target=kmsg"
    "log_buf_len=1M"
  ];
}
