{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.me) gui;
in
lib.mkIf (gui.enable && gui.displayServer == "xorg") {
  nixpkgs.overlays = [
    (final: prev: {
      grobi = prev.grobi.overrideAttrs (old: rec {
        version = "8172a9fbaccb94aa9e5fac055b55a260c3a3a8b9";
        src = pkgs.fetchFromGitHub {
          owner = "jonaz";
          repo = "grobi";
          rev = version;
          sha256 = "mboaYybsSS5HX1EjiZMlSlVvtUz6gLrMtp8dN897IM4=";
        };

        patches = [ ];
        vendorHash = "sha256-3hyI5oHV8qEkIsF6pk1xx1H98Wx+Ug/Z2IswVbzIQLQ=";
      });
    })
  ];

  services.grobi.enable = true;

  xsession.numlock.enable = true;
  xsession.initExtra = # bash
    ''
      ${pkgs.xset}/bin/xset s off -dpms
    '';

  xdg.configFile."zsh/.zshrc".text =
    lib.mkBefore ''[[ $(tty) == "/dev/tty1" ]] && exec startx &> /dev/null'';
}
