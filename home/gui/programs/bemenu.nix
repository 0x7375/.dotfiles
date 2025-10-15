{
  pkgs,
  inputs,
  myLib,
  config,
  lib,
  ...
}:

lib.mkIf config.me.gui.enable {
  nixpkgs.overlays = [
    (final: prev: {
      bemenu = inputs.wrappers.lib.wrapPackage {
        pkgs = prev;
        package = prev.bemenu;
        preHook = ''
          xget() {
            xrdb -query | grep "$1:" | cut -f2
          }

          bg0_dark=$(xget bg0_dark)
          fg0=$(xget fg0)

          BEMENU_OPTS="$BEMENU_OPTS --tb $bg0_dark --fb $bg0_dark --nb $bg0_dark --ab $bg0_dark --scb $bg0_dark --bdr $bg0_dark --hf $bg0_dark"
          BEMENU_OPTS="$BEMENU_OPTS --nf $fg0 --tf $fg0 --ff $fg0 --hb $fg0 --sb $fg0 --cb $fg0 --cf $fg0 --sf $fg0 --af $fg0 --scf $fg0"

          export BEMENU_OPTS
        '';
      };
    })
  ];

  home.sessionVariables.BEMENU_OPTS = lib.cli.toGNUCommandLineShell { } {
    border = 7;
    hp = 10;
    fn = "Mononoki Nerd Font ${toString myLib.bar.font-size}";
    ignorecase = true;
  };

  home.packages = [ pkgs.bemenu ];
}
