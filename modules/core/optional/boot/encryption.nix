{
  mkNixos,
  lib,
  config,
  ...
}:

lib.mkIf config.me.boot.encryption.enable (mkNixos {
  # don't fail when a password is entered while the key isn't plugged in
  boot.initrd.systemd.services."systemd-cryptsetup@crypted" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      ExecStart = lib.mkForce [
        ""
        "/bin/sh -c 'while ! /bin/systemd-cryptsetup attach crypted ${config.boot.initrd.luks.devices.crypted.device} - fido2-device=auto,token-timeout=0; do rm -f /run/systemd/ask-password/*; sleep 1; done'"
      ];
    };
  };

  boot.initrd.luks.devices.crypted.crypttabExtraOpts = [
    "fido2-device=auto"
    "token-timeout=0"
  ];

  # prevent luks pw prompt from timing out
  boot.initrd.systemd.settings.Manager.DefaultDeviceTimeoutSec = "infinity";
})
