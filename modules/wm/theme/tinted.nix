{
  lib,
  config,
  mkBundle,
  ...
}:

let
  inherit (config.me) user home;
  path = home + "/.local/state/tinted/theme";
in
lib.mkIf config.me.wm.enable (mkBundle {
  tinted.enable = true;
  vars.TINTED_FILE = path;

  nixos.systemd.user.tmpfiles.rules = [
    "f ${path} 0644 ${user} users - dark"
  ];

  darwin.activation = ''
    [[ ! -f ${path} ]] && echo "dark" > ${path}
  '';
})
