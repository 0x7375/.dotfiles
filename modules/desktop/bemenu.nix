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
                source "$HOME/.local/state/tinted/palette"

                BEMENU_OPTS="$BEMENU_OPTS --ignorecase --hp=10 --border=10"
                BEMENU_OPTS="$BEMENU_OPTS --tb #$bg0_dark --fb #$bg0_dark --nb #$bg0_dark --ab #$bg0_dark --scb #$bg0_dark --bdr #$bg0_dark --hf #$bg0_dark"
                BEMENU_OPTS="$BEMENU_OPTS --nf #$fg0 --tf #$fg0 --ff #$fg0 --hb #$fg0 --sb #$fg0 --cb #$fg0 --cf #$fg0 --sf #$fg0 --af #$fg0 --scf #$fg0"

                export BEMENU_OPTS
              ''
            ];
          };
        })
      ];
    };
}
