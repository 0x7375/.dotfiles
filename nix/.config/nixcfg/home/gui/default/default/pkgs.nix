{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  home.packages =
    with pkgs;
    let
      st = pkgs.st.overrideAttrs (old: {
        src = pkgs.fetchFromSourcehut {
          owner = "~ayko";
          repo = "st";
          rev = "main";
          hash = "sha256-DYgWO9FHX7z0gtdlDuxojzyT1ezGvUau7AzuFnHr5i4=";
        };
      });
    in
    [
      auto.ente-auth

      scripts.update-icons-color

      # audio
      pavucontrol
      pamixer

      # image/video
      imagemagick
      obs-studio
      gimp
      krita
      gthumb
      vlc
      celluloid
      jellyfin-media-player
      sushi
      ffmpeg

      # files
      gparted
      nautilus
      gnome-disk-utility
      file-roller
      ntfs3g

      mimeo
      blueberry
      dia
      gnome-calculator
      melonDS
      perl538Packages.FileMimeInfo
      qbittorrent
      scrcpy
      vmware-horizon-client
      ungoogled-chromium
      signal-desktop
      st
    ]
    ++ (lib.optionals config.me.devPkgs.enable [
      nodePackages.eas-cli

      # haskell
      ghc

      # php
      php
      # nodePackages.intelephense
      nodePackages.browser-sync

      # java
      zulu
      ant
      maven

      # sql
      mariadb

      # c
      clang-tools
      gnumake
      gcc

      texliveMedium
      python3
      taplo
      jq

      android-studio
      jetbrains.idea-community

      # codium
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions =
          with vscode-extensions;
          [
            jnoortheen.nix-ide
            jdinhlife.gruvbox
            haskell.haskell
            justusadam.language-haskell
            asvetliakov.vscode-neovim
            ms-python.python
            redhat.java
            mkhl.direnv
          ]
          ++ vscode-utils.extensionsFromVscodeMarketplace [
            # {
            #   name = "everforest";
            #   publisher = "sainnhe";
            #   version = "0.3.0";
            #   sha256 = "nZirzVvM160ZTpBLTimL2X35sIGy5j2LQOok7a2Yc7U=";
            # }
          ];
      })
    ]);
}
