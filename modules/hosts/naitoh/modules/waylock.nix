{
  flake.modules.nixos.naitoh =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      nixpkgs.overlays = [
        (_: prev: {
          waylock = prev.writeShellScriptBin "waylock" ''
            source ${config.me.home}/${config.tinted.stateDir}/palette
            exec ${lib.getExe prev.waylock} \
              -init-color  "0x$bg0" \
              -input-color "0x$bg1" \
              -fail-color  "0x$red" \
              "$@"
          '';
        })
      ];

      packages = [ pkgs.waylock ];

      security.pam.services.waylock = {
        u2fAuth = true;
        unixAuth = false;
      };
    };
}
