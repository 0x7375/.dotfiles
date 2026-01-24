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

      texliveFull
      typst
      gnome-calculator
      qbittorrent
      # st
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      (auto.discord.override {
        # withOpenASAR = true;
        withVencord = true;
      })
      ungoogled-chromium
      scripts.generate-icons
      omnissa-horizon-client
      auto.signal-desktop
      stable.gaphor
      # stable.jetbrains.idea-community
    ])
    ++ (lib.optionals config.me.dev.enable [
    ]);
}
