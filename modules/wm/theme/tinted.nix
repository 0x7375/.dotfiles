{
  pkgs,
  lib,
  config,
  options,
  ...
}:

let
  inherit (config.me) user home;
  path = home + "/.local/state/tinted/theme";
in
lib.mkIf config.me.wm.enable (
  lib.mkMerge [
    {
      tinted.enable = true;
      vars.TINTED_FILE = path;
    }
    (lib.optionalAttrs (options ? systemd) {
      systemd.user.tmpfiles.rules = [
        "f ${path} 0644 ${user} users - dark"
      ];
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      system.activationScripts.tinted-state.text = ''
        [[ ! -f ${path} ]] && echo "dark" > ${path}
      '';
    })
  ]
)
