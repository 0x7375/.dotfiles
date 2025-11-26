{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.spicetify-nix.nixosModules.default
  ];

  config = lib.mkIf config.me.wm.enable {
    unfree-packages = [ "spotify" ];

    programs.spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        enable = true;
        enabledExtensions =
          with spicePkgs.extensions;
          [
            shuffle
            adblock
          ]
          ++ [
            # {
            #   src =
            #     pkgs.fetchFromGitHub {
            #       owner = "Resxt";
            #       repo = "Spicetify-Extensions";
            #       rev = "main";
            #       sha256 = "sha256-+Th5o00c3Y8U+Y/RGmRSkWWp97YCoCJmoESFLZf9dwM=";
            #     }
            #     + "/startup-page/dist";
            #   name = "startup-page.js";
            # }
          ];
        enabledCustomApps = with spicePkgs.apps; [ marketplace ];
        enabledSnippets = with spicePkgs.snippets; [
          disableRecommendations
          hideFriendActivityButton
          hideMadeForYou
          hideMiniPlayerButton
          hideNowPlayingViewButton
          hidePlayingGif
          hideRecentlyPlayed
          hideRecentSearches
          hideWhatsNewButton
          removePopular
          removeRecentlyPlayed
          removePlaylistCover

          # hide useless message from betterLibrary
          ''
            .betterLibText { 
              display: none !important; 
            }
          ''
          # hide "scroll through previews"
          ''
            .main-actionBar-exploreButton { display: none !important; }
          ''
        ];
        wayland = config.me.wm.displayServer == "wayland";
        theme = {
          name = "Blackout";
          src = "${
            pkgs.fetchFromGitHub {
              owner = "spicetify";
              repo = "spicetify-themes";
              rev = "726097a544172523cdae15da8d3c84032aec8c3b";
              sha256 = "sha256-mQgkmbkgzfWlT1iv4jB/cw95v4q0/+57B9rgmezAY34=";
            }
          }/Blackout";
        };
        colorScheme = "def";
      };
  };
}
