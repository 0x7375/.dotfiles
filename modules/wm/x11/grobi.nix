{
  mkNixos,
  lib,
  pkgs,
  config,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "xorg") (mkNixos {
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

  packages = [ pkgs.grobi ];

  hj.xdg.config.files."grobi.conf" = {
    generator = lib.generators.toJSON { };
    value.execute_after = [ ];
  };

  systemd.user.services.grobi = {
    description = "grobi display auto config daemon";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    restartTriggers = [
      config.hj.xdg.config.files."grobi.conf".source
    ];

    path = [
      pkgs.xorg.xrandr
      pkgs.bash
    ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.grobi} watch -v";
      Restart = "always";
      RestartSec = "2s";
    };

    wantedBy = [ "graphical-session.target" ];
  };
})
