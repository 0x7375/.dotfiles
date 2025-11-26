{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable {
  unfree-packages = [
    "discord"
    "omnissa-horizon-client"
  ];

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
      gnome-text-editor
      calibre
      ungoogled-chromium

      (auto.discord.override {
        # withOpenASAR = true;
        withVencord = true;
      })

      scripts.generate-icons

      gnome-calculator
      qbittorrent
      omnissa-horizon-client
      auto.signal-desktop
      # st
    ]
    ++ [
    ]
    ++ (lib.optionals config.me.dev.enable [
      apache-hop

      # php
      nodePackages.browser-sync

      texliveFull
      typst

      # stable.jetbrains.idea-community

      stable.gaphor
    ]);
}
