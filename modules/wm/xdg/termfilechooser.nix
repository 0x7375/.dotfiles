{
  mkNixos,
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  nixpkgs.overlays = [
    (final: prev: {
      xdg-desktop-portal-termfilechooser =
        prev.xdg-desktop-portal-termfilechooser.overrideAttrs
          (old: rec {
            version = "caf24e77189f500b6a27ef502ef01d3a96196510";
            src = pkgs.fetchFromGitHub {
              owner = old.src.owner;
              repo = old.src.repo;
              rev = "${version}";
              sha256 = "2A+y6twdfLl/Fy4Feop3tMGfTytxX80acTrFQ56kjS4=";
            };
          });

      file-handler = pkgs.stdenv.mkDerivation {
        name = "file-handler";
        src = ./.;
        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          dbus.dev
          pkg-config
        ];

        buildPhase = ''
          gcc -o file-handler $src/file-handler.c $(pkg-config --cflags --libs dbus-1)
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp file-handler $out/bin
        '';

        meta.mainProgram = "file-handler";
      };
    })
  ];

  xdg.portal = {
    extraPortals = [
      pkgs.xdg-desktop-portal-termfilechooser
    ];
    config.common."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
  };

  vars = {
    GDK_DEBUG = "portals";
    GTK_USE_PORTAL = "1";
  };

  hj.xdg.config.files."xdg-desktop-portal-termfilechooser/config".text =
    let
      env = pkgs.buildEnv {
        name = "lf-wrapper-env";
        paths = with pkgs; [
          lf
          gnused
          coreutils
          bashInteractive
          zsh
          git
        ];
      };
      inherit (config.me.wm) terminal;
    in
    # ini
    ''
      [filechooser]
      env=PATH='${env}/bin'
      env=TERMCMD='${pkgs.${terminal.name}}/bin/${terminal.cmd} -T filechooser -e'
      cmd='${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/lf-wrapper.sh'
      default_dir=$XDG_DOWNLOAD_DIR
    '';

  me.wm.floating = [
    {
      type = "title";
      name = "filechooser";
    }
  ];

  vars.QT_QPA_PLATFORMTHEME = "xdgdesktopportal";

  systemd.user.services."file-handler".serviceConfig.ExecStart = "${lib.getExe pkgs.file-handler}";

  hj.xdg.data.files."dbus-1/services/org.freedesktop.FileManager1.service".text = # ini
    ''
      [D-BUS Service]
      Name=org.freedesktop.FileManager1
      Exec=${lib.getExe pkgs.file-handler}
    '';
})
