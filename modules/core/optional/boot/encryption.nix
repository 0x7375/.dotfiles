{
  mkNixos,
  lib,
  config,
  ...
}:

lib.mkIf config.me.boot.encryption.enable (mkNixos {
  boot.initrd.luks.devices.crypted.crypttabExtraOpts = [
    "fido2-device=auto"
    "token-timeout=0"
  ];
})
