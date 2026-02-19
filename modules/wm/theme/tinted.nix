{
  lib,
  config,
  mkBundle,
  ...
}:

let
  inherit (config.me) home;
  path = home + "/.local/state/tinted/theme";
in
lib.mkIf config.me.wm.enable (mkBundle {
  tinted.enable = true;
  vars.TINTED_FILE = path;
})
