{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  nixpkgs.overlays = [
    (final: prev: {
      grobi = prev.grobi.overrideAttrs (old: {
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "jonaz";
          repo = "grobi";
          rev = "master";
          hash = "sha256-mboaYybsSS5HX1EjiZMlSlVvtUz6gLrMtp8dN897IM4=";
        };

        patches = [ ];
        vendorHash = "sha256-3hyI5oHV8qEkIsF6pk1xx1H98Wx+Ug/Z2IswVbzIQLQ=";
      });
    })
  ];

  services = {
    # make physical playback buttons work
    mpris-proxy.enable = true;

    playerctld.enable = true;
    grobi.enable = true;

    gromit-mpx = {
      enable = true;
      hotKey = null;
      undoKey = null;
    };
  };
}
