{
  pkgs,
  config,
  mkNixos,
  lib,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "xorg" && config.me.secrets.enable) (mkNixos {
  sops.secrets.coordinates = {
    owner = config.me.user;
  };

  services.redshift.enable = true;

  location = {
    latitude = 0.0;
    longitude = 0.0;
  };

  systemd.user.services.redshift.serviceConfig.ExecStart = lib.mkForce (
    pkgs.writeShellScript "redshift-start" ''
      set -euo pipefail
      exec ${lib.getExe pkgs.redshift} \
        -l "$(cat ${config.sops.secrets.coordinates.path})" \
        -t 6500:3000 \
        -v
    ''
  );
})

