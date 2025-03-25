{
  pkgs,
  lib,
  myLib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {

  # home.packages = with pkgs; [
  #   inputs.zen-browser.packages."${system}".specific
  # ];

  home.file.".librewolf/native-messaging-hosts/com.1password.1password.json".text = # json
    ''
      {
        "name": "com.1password.1password",
        "description": "1Password BrowserSupport",
        "path": "/run/wrappers/bin/1Password-BrowserSupport",
        "type": "stdio",
        "allowed_extensions": [
          "{0a75d802-9aed-41e7-8daa-24c067386e82}",
          "{25fc87fa-4d31-4fee-b5c1-c32a7844c063}",
          "{d634138d-c276-4fc8-924b-40a0ea21d284}"
        ]
      }
    '';

  programs.librewolf = {
    enable = true;
    profiles.alt = {
      isDefault = false;
      id = 1;
    };
    profiles.default =
      let
        refreshRate = config.me.refreshRate;
        fastfox = import ./fastfox.nix;
        peskyfox = import ./peskyfox.nix;
        securefox = import ./securefox.nix;
        smoothfox =
          if refreshRate == 60 then
            {
              "general.smoothScroll" = true;
              "mousewheel.default.delta_multiplier_y" = 275; # 250-400
            }
          else
            {
              "general.smoothScroll" = true;
              "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
              "general.smoothScroll.msdPhysics.enabled" = true;
              "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;
              "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
              "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
              "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
              "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
              "general.smoothScroll.currentVelocityWeighting" = "1";
              "general.smoothScroll.stopDecelerationWeighting" = "1";
              "mousewheel.default.delta_multiplier_y" = 300; # 250-400
            };
      in
      {
        isDefault = true;
        settings =
          let
            inherit (myLib) palette;
          in
          fastfox
          // securefox
          // peskyfox
          // smoothfox
          // {
            # ui state
            "browser.uiCustomization.state" = # json
              ''
                {
                  "placements": {
                    "widget-overflow-fixed-list": [],
                    "unified-extensions-area": [
                      "dearrow_ajay_app-browser-action",
                      "sponsorblocker_ajay_app-browser-action",
                      "ublock0_raymondhill_net-browser-action",
                      "moz-addon-prod_7tv_app-browser-action",
                      "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action",
                      "myallychou_gmail_com-browser-action",
                      "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action",
                      "addon_darkreader_org-browser-action",
                      "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action",
                      "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action",
                      "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
                    ],
                    "nav-bar": [
                      "customizableui-special-spring1",
                      "urlbar-container",
                      "customizableui-special-spring2",
                      "save-to-pocket-button",
                      "downloads-button",
                      "unified-extensions-button",
                      "forward-button",
                      "back-button"
                    ],
                    "toolbar-menubar": [
                      "menubar-items"
                    ],
                    "TabsToolbar": [
                      "firefox-view-button",
                      "tabbrowser-tabs",
                      "new-tab-button",
                      "alltabs-button"
                    ],
                    "vertical-tabs": [],
                    "PersonalToolbar": [
                      "import-button",
                      "personal-bookmarks"
                    ]
                  },
                  "seen": [
                    "developer-button",
                    "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action",
                    "moz-addon-prod_7tv_app-browser-action",
                    "myallychou_gmail_com-browser-action",
                    "ublock0_raymondhill_net-browser-action",
                    "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action",
                    "sponsorblocker_ajay_app-browser-action",
                    "dearrow_ajay_app-browser-action",
                    "addon_darkreader_org-browser-action",
                    "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action",
                    "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action",
                    "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
                  ],
                  "dirtyAreaCache": [
                    "nav-bar",
                    "vertical-tabs",
                    "unified-extensions-area",
                    "PersonalToolbar",
                    "toolbar-menubar",
                    "TabsToolbar"
                  ],
                  "currentVersion": 20,
                  "newElementCount": 5
                }
              '';

            # disable fingerprinting protection
            "privacy.resistFingerprinting" = false;

            # enable Firefox Sync
            "identity.fxaccounts.enabled" = true;

            # disable login manager
            "signon.rememberSignons" = false;

            # disable address and credit card manager
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;

            # delete all browsing data on shutdown
            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
            "privacy.clearOnShutdown.downloads" = false;
            "privacy.clearOnShutdown.formdata" = true;
            "privacy.clearOnShutdown.sessions" = true;
            "privacy.clearOnShutdown.cache" = true;
            "privacy.clearOnShutdown.cookies" = true;
            "privacy.clearOnShutdown.offlineApps" = true;
            "privacy.clearOnShutdown.siteSettings" = false;

            # play DRM content
            "media.eme.enabled" = true;

            # restore previous windows and tabs
            "browser.startup.page" = 3;

            # set new tab and homepage to a blank page
            "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
            "browser.newtabpage.enabled" = false;

            # same search engine for private windows
            "browser.search.separatePrivateDefault.ui.enabled" = false;

            # do not prompt for translate
            "browser.translations.automaticallyPopup" = false;

            # send a do not track request
            "privacy.donottrackheader.enabled" = true;

            # hide firefox suggest
            "browser.urlbar.groupLabels.enabled" = false;

            # maximum of 6 history entries in adress bar
            "browser.urlbar.maxRichResults" = 6;

            # disable some suggested stuff in adress bar
            "browser.urlbar.suggest.openpage" = false;
            "browser.urlbar.suggest.engines" = false;
            "browser.urlbar.suggest.topsites" = false;

            # use default dns provider
            "network.trr.mode" = 5;

            # disable picture in picture controls
            "media.videocontrols.picture-in-picture.enabled" = false;

            # parallel downloads
            "network.http.max-persistent-connections-per-server" = 10;

            # change blank pages background color
            "browser.display.background_color.dark" = "${palette.bg0}";

            # middlemouse paste
            "middlemouse.paste" = false;

            # general autoscroll
            "general.autoScroll" = true;

            # enable mozilla verified extensions on restricted domains
            "extensions.webextensions.restrictedDomains" = " ";
            "privacy.resistFingerprinting.block_mozAddonManager" = true;

            "browser.search.region" = "en-US";
            "browser.search.update.region" = "en-US";

            # hide bookmarks toolbar
            "browser.toolbars.bookmarks.visibility" = "never";

            # disable disk cache
            "browser.cache.disk.enable" = false;

            # https only mode
            "dom.security.https_only_mode" = true;

            # just save downloaded files
            "browser.download.always_ask_before_handling_new_types" = false;

            # disable search bar on homepage
            "browser.newtabpage.activity-stream.showSearch" = false;

            # no beep of search
            "accessibility.typeaheadfind.enablesound" = false;

            # always request canvas permission
            "privacy.resistFingerprinting.autoDeclineNoUserInputCanvasPrompts" = true;

            # disable webgl
            "webgl.disabled" = true;

            # disable autoplay
            "media.autoplay.blocking_policy" = 2;
          };
        userChrome = builtins.readFile ./userChrome.css;
        search = {
          force = true;
          default = "_Google";
          order = [
            "_Google"
            "Google Images"
            "Brave"
            "Brave Images"
            "Nix Packages"
            "Nix Options"
            "Youtube"
            "Github"
            "Wikipedia (en)"
          ];
          engines =
            let
              day = 24 * 60 * 60 * 1000;
            in
            {
              # "Google".metaData.hidden = true;
              # "Bing".metaData.hidden = true;
              # "eBay".metaData.hidden = true;
              # "DuckDuckGo".metaData.hidden = true;
              # "Qwant".metaData.hidden = true;
              "Wikipedia (en)".metaData.alias = "!w";

              "_Google" = {
                urls = [
                  {
                    template = "https://google.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/google.com.ico";
                updateInterval = day;
                metaData.alias = "!g";
              };
              "Google Images" = {
                urls = [
                  {
                    template = "https://google.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                      {
                        name = "tbm";
                        value = "isch";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/google.com.ico";
                updateInterval = day;
                metaData.alias = "!gi";
              };
              "Dofus" = {
                urls = [
                  {
                    template = "https://www.dofuspourlesnoobs.com/apps/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/dofuspourlesnoobs.com.ico";
                updateInterval = day;
                metaData.alias = "!d";
              };
              "Brave" = {
                urls = [
                  {
                    template = "https://search.brave.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/brave.com.ico";
                updateInterval = day;
                metaData.alias = "!b";
              };
              "Brave Images" = {
                urls = [
                  {
                    template = "https://search.brave.com/images";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/brave.com.ico";
                updateInterval = day;
                metaData.alias = "!bi";
              };
              "Nix Options" = {
                urls = [
                  {
                    template = "https://mynixos.com/search";
                    params = [
                      {
                        name = "q";
                        value = "option+{searchTerms}";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/mynixos.com.ico";
                updateInterval = day;
                metaData.alias = "!o";
              };
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://mynixos.com/search";
                    params = [
                      {
                        name = "q";
                        value = "package+{searchTerms}";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/mynixos.com.ico";
                updateInterval = day;
                metaData.alias = "!p";
                # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              };
              "Nixhub" = {
                urls = [
                  {
                    template = "https://www.nixhub.io/packages/{searchTerms}";
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/mynixos.com.ico";
                updateInterval = day;
                metaData.alias = "!u";
              };
              "Github" = {
                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                      {
                        name = "type";
                        value = "repositories";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/github.com.ico";
                updateInterval = day;
                metaData.alias = "!h";
              };
              "Youtube" = {
                urls = [
                  {
                    template = "https://www.youtube.com/results";
                    params = [
                      {
                        name = "search_query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/youtube.com.ico";
                updateInterval = day;
                metaData.alias = "!y";
              };
              "Conjugaison" = {
                urls = [
                  {
                    template = "https://conjugaison.bescherelle.com/verbe/{searchTerms}";
                  }
                ];

                iconUpdateURL = "https://icons.duckduckgo.com/ip3/conjugaison.bescherelle.com.ico";
                updateInterval = day;
                metaData.alias = "!c";
              };
            };
        };
      };
  };
}
