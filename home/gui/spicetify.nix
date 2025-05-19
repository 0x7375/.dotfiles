{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  config = lib.mkIf config.me.gui.enable {
    home.packages = with pkgs; [
      spotify
    ];

    programs.spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
      in
      {
        enable = false;
        enabledExtensions =
          with spicePkgs.extensions;
          [
            shuffle
            # betterGenres
          ]
          ++ [
            # {
            #   src =
            #     pkgs.fetchFromGitHub {
            #       owner = "0xB0F";
            #       repo = "Spicetify-Extensions";
            #       rev = "main";
            #       sha256 = "sha256-+Th5o00c3Y8U+Y/RGmRSkWWp97YCoCJmoESFLZf9dwM=";
            #     }
            #     + "/startup-page/dist";
            #   name = "startup-page.js";
            # }
          ];
        enabledCustomApps = with spicePkgs.apps; [
          # marketplace
          # betterLibrary
        ];
        enabledSnippets = with spicePkgs.snippets; [
          # removePopular
          # hideFriendActivityButton
          # hidePlayingGif
          # hideRecentlyPlayed
          # hideRecentSearches
          # hideWhatsNewButton
          # hideMadeForYou
          # removeRecentlyPlayed
          # hideNowPlayingViewButton
          # hideMiniPlayerButton
        ];
        # theme = {
        #   src = spicePkgs.sources.lucidSrc + "/src";
        #   name = "lucid";
        #   colorscheme = "dark";
        #   overwriteAssets = true;
        #
        #   injectCss = true;
        #   injectThemeJs = true;
        #   replaceColors = true;
        #
        #   requiredExtensions = [
        #     {
        #       src = spicePkgs.sources.lucidSrc + "/src";
        #       name = "theme.js";
        #     }
        #   ];
        #   additionalCss = # css
        #     ''
        #       .Root__top-container {
        #         gap: var(--panel-gap) 0 !important;
        #       }
        #       #Desktop_LeftSidebar_Id {
        #         display: none !important;
        #       }
        #     '';
        # };
      };
  };
}
