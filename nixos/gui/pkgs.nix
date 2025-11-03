{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {

  nixpkgs.overlays = [
    (final: prev: {
      pamixer = prev.pamixer.overrideAttrs (oldAttrs: {
        # Follow recommended fix from NixOS issue #394444
        cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
          "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
        ];
      });
    })
  ];

  unfree-packages = [ "discord" "omnissa-horizon-client" "android-studio-stable" ];

  packages =
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
      calibre

      (auto.discord.override {
        # withOpenASAR = true;
        withVencord = true;
      })

      scripts.generate-icons

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
      # insecure because of qt5: https://github.com/nixos/nixpkgs/issues/437865
      # auto.jellyfin-media-player
      ffmpeg-full

      # files
      nautilus
      file-roller
      ntfs3g

      mimeo
      blueberry
      stable.gaphor
      gnome-calculator
      melonDS
      ryubing
      dolphin-emu
      perl538Packages.FileMimeInfo
      qbittorrent
      scrcpy
      omnissa-horizon-client
      auto.signal-desktop
      # st
    ]
    ++ [
    ]
    ++ (lib.optionals config.me.devPkgs.enable [
      gnumake
      deno

      go
      delve

      apache-hop

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
      sqlite
      litecli

      # c
      clang-tools
      gcc
      bear
      gdb

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
            golang.go
            llvm-vs-code-extensions.vscode-clangd
          ]
          ++ vscode-utils.extensionsFromVscodeMarketplace [
            # {
            #   name = "everforest";
            #   publisher = "sainnhe";
            #   version = "0.3.0";
            #   sha256 = "nZirzVvM160ZTpBLTimL2X35sIGy5j2LQOok7a2Yc7U=";
            # }
            {
              name = "debug";
              publisher = "webfreak";
              version = "0.27.0";
              sha256 = "p/k5UcXldXKFKbPbnW603Jsut53n01azeDhWMDSd4nw=";
            }
          ];
      })
    ]);
}
