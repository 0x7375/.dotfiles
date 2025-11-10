{ config, ... }:

let
  path = "$HOME/.local/state/tinted/theme";
in
{
  tinted.enable = true;

  systemd.user.tmpfiles.rules = [
    "f ${path} 0644 root root - dark"
  ];

  vars.TINTED_FILE = path;
}
