{
  lib,
  config,
  pkgs,
  mkBundle,
  ...
}:

lib.mkIf config.me.wm.enable (mkBundle {
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
      ungoogled-chromium
      texliveMedium
      typst
      gnome-calculator
      qbittorrent
      # st
    ];

  nixos = {
    unfree-packages = [
      "discord"
      "omnissa-horizon-client"
      "google-chrome"
    ];

    packages = with pkgs; [
      # (auto.discord.override {
      #   # withOpenASAR = true;
      #   withVencord = true;
      # })
      vesktop
      google-chrome
      my.generate-icons
      omnissa-horizon-client
      auto.signal-desktop
      stable.gaphor
      # stable.jetbrains.idea-community
    ];
  };
})
