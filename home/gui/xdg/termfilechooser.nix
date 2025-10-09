{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.gui.enable {
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

  home.packages = [ pkgs.xdg-desktop-portal-termfilechooser ];

  home.sessionVariables = {
    GDK_DEBUG = "portals";
    GTK_USE_PORTAL = "1";
  };

  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-termfilechooser
  ];

  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text =
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
      term = config.me.gui.terminal;
    in
    # ini
    ''
      [filechooser]
      env=PATH='${env}/bin'
      env=TERMCMD='${pkgs.${term}}/bin/${term} -T filechooser -e'
      cmd='${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/lf-wrapper.sh'
      default_dir=${config.xdg.userDirs.download}
    '';

  xdg.desktopEntries."swap-file-chooser" = {
    exec = "${pkgs.writeShellScript "swap-file-chooser" ''
      CONFIG="$HOME/.config/xdg-desktop-portal/portals.conf"
      sed -i 's/gtk;termfilechooser/TEMP/' "$CONFIG" && \
      sed -i 's/termfilechooser;gtk/gtk;termfilechooser/' "$CONFIG" && \
      sed -i 's/TEMP/termfilechooser;gtk/' "$CONFIG"
      systemctl --user restart xdg-desktop-portal
    ''}";
    name = "Swap File Chooser";
  };

  xdg.configFile."xdg-desktop-portal/portals.conf" = {
    mutable = true;
    force = true;
    text = # ini
      ''
        [preferred]
        default=*
        org.freedesktop.impl.portal.FileChooser=termfilechooser;gtk
      '';
  };

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
  };

  systemd.user.services."file-handler" = {
    Service.ExecStart = "${lib.getExe pkgs.file-handler}";
  };

  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service".text = # ini
    ''
      [D-BUS Service]
      Name=org.freedesktop.FileManager1
      Exec=${lib.getExe pkgs.file-handler}
    '';
}
