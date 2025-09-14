{
  inputs,
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
        src = fetchFromGitea {
          domain = "codeberg.org";
          owner = "0x7E";
          repo = "st";
          rev = "main";
          sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        };
      });
    in
    [
      protonvpn-gui
      stable.ente-auth
      gnome-text-editor

      (discord.override {
        withOpenASAR = true;
        withVencord = false;
      })

      scripts.update-icons-color

      # audio
      pavucontrol
      pamixer

      # image/video
      imagemagick
      obs-studio
      gimp
      # kdePackages.kdenlive
      sly
      vlc
      celluloid
      jellyfin-media-player
      ffmpeg-full

      # files
      nautilus
      file-roller
      ntfs3g

      mimeo
      blueberry
      dia
      gnome-calculator
      melonDS
      ryubing
      dolphin-emu
      perl538Packages.FileMimeInfo
      qbittorrent
      scrcpy
      vmware-horizon-client
      auto.ungoogled-chromium
      auto.mullvad-browser
      signal-desktop
      # st
    ]
    ++ [
    ]
    ++ (lib.optionals config.me.devPkgs.enable [
      gnumake
      deno

      go

      # nodePackages.eas-cli

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
      gcc

      texliveFull
      typst
      python3
      taplo
      jq

      android-studio
      # stable.jetbrains.idea-community

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
