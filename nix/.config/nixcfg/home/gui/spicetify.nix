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
    # home.packages = with pkgs; [
    #   spotify
    # ];

    programs.spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
      in
      {
        enable = true;
        enabledExtensions =
          with spicePkgs.extensions;
          [
            shuffle
            keyboardShortcut
            betterGenres
          ]
          ++ [
            {
              src =
                pkgs.fetchFromGitHub {
                  owner = "0xB0F";
                  repo = "Spicetify-Extensions";
                  rev = "main";
                  sha256 = "sha256-+Th5o00c3Y8U+Y/RGmRSkWWp97YCoCJmoESFLZf9dwM=";
                }
                + "/startup-page/dist";
              name = "startup-page.js";
            }
            {
              src = pkgs.fetchFromGitHub {
                owner = "kyrie25";
                repo = "spicetify-utilities";
                rev = "main";
                sha256 = "sha256-LZcrmoA+SOpTeTiBeiOtneojzBhvbZfkawTyFRLhNk8=";
              };
              name = "utilities.js";
            }
          ];
        enabledCustomApps = with spicePkgs.apps; [
          marketplace
          betterLibrary
        ];
        enabledSnippets = with spicePkgs.snippets; [
          removePopular
          hideFriendActivityButton
          hidePlayingGif
          hideRecentlyPlayed
          hideRecentSearches
          hideWhatsNewButton
          hideMadeForYou
          removeRecentlyPlayed
          hideNowPlayingViewButton
          hideMiniPlayerButton
          hideFullScreenButton
        ];
        # theme
        # theme = {
        #   # https://github.com/Gerg-L/spicetify-nix/blob/master/pkgs/themes.nix
        #   name = "text";
        #   src = "${spicePkgs.sources.officialThemes}/text";
        #   patches = {
        #     "xpui.js_find_8008" = ",(\\w+=)56";
        #     "xpui.js_repl_8008" = ",\${1}32";
        #   };
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
        # colorScheme = "Gruvbox";
      };
  };
}
