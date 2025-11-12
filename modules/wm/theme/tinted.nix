{ lib, config, ... }:

let
  inherit (config.me) user home;
  path = home + "/.local/state/tinted/theme";
in
lib.mkIf config.me.wm.enable {
  tinted.enable = true;

  systemd.user.tmpfiles.rules = [
    "f ${path} 0644 ${user} users - dark"
  ];

  vars.TINTED_FILE = path;
}
