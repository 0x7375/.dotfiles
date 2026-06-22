{ inputs, ... }:

{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      packages = [ pkgs.bemenu ];

      nixpkgs.overlays = [
        (final: prev: {
          bemenu = inputs.wrappers.lib.wrapPackage {
            pkgs = prev;
            package = prev.bemenu;
            runShell = [
              # bash
              ''
                source "$TINTED_DIR/palette.env"

                BEMENU_OPTS="$BEMENU_OPTS --ignorecase --hp=10 --border=10"
                BEMENU_OPTS="$BEMENU_OPTS --tb #$bg0_hard --fb #$bg0_hard --nb #$bg0_hard --ab #$bg0_hard --scb #$bg0_hard --bdr #$bg0_hard --hf #$bg0_hard"
                BEMENU_OPTS="$BEMENU_OPTS --nf #$fg0 --tf #$fg0 --ff #$fg0 --hb #$fg0 --sb #$fg0 --cb #$fg0 --cf #$fg0 --sf #$fg0 --af #$fg0 --scf #$fg0"

                export BEMENU_OPTS
              ''
            ];
          };
        })
      ];
    };
}
