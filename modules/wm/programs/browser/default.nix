{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.me.palette) dark;
in
lib.mkIf config.me.wm.enable {
  packages = with pkgs; [
    zen-browser
    auto.librewolf
  ];

  hj.files.".zen/native-messaging-hosts/com.1password.1password.json".text = # json
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

  hj.files.".librewolf/default".type = "directory";
  hj.files.".librewolf/profiles.ini".text = config.hj.files.".zen/profiles.ini".text;

  hj.files.".zen/default".type = "directory";
  hj.files.".zen/profiles.ini" = {
    generator = lib.generators.toINI { };
    value = {
      Profile0 = {
        Name = "default";
        IsRelative = 1;
        Path = "default";
        Default = 1;
      };

      General = {
        StartWithLastProfile = 1;
        Version = 2;
      };
    };
  };

  # required for zen to load the custom profile
  vars.MOZ_LEGACY_PROFILES = 1;

  hj.files.".librewolf/default/chrome/userChrome.css".text = builtins.readFile ./userChrome.css;
  hj.files.".zen/default/chrome/userChrome.css".text =
    # css
    ''
      /* change selected urlbar result font color */
      /* .urlbarView-row { */
      /*   &[selected] { */
      /*     & * { */
      /*       color: ${dark.fg0} !important; */
      /*     } */
      /*   } */
      /* } */

      /* change selected urlbar result icon bg color */
      /* .urlbarView-row { */
      /*   &[selected] { */
      /*     & .urlbarView-favicon { */
      /*       background-color: transparent !important; */
      /*     } */
      /*   } */
      /* } */

      /* hide workspace indicator */
      #zen-current-workspace-indicator-container {
        display: none;
      }

      /* disable animations */
      * { animation: none !important; transition: none !important; }
    '';

  hj.files.".zen/default/zen-keyboard-shortcuts.json".text = (
    builtins.readFile ./zen-keyboard-shortcuts.json
  );
  # TODO declarative zen mods
  # hj.files.".zen/default/zen-themes.json".text = (builtins.readFile ./zen-themes.json);

  hj.files.".zen/default/user.js".text =
    let
      userPrefValue =
        pref:
        builtins.toJSON (
          if lib.isBool pref || lib.isInt pref || lib.isString pref then pref else builtins.toJSON pref
        );

      mkUserJs =
        prefs:
        lib.concatStrings (
          lib.mapAttrsToList (name: value: ''
            user_pref("${name}", ${userPrefValue value});
          '') prefs
        );

      fastfox = import ./_fastfox.nix;
      peskyfox = import ./_peskyfox.nix;
      securefox = import ./_securefox.nix;
      smoothfox =
        if config.me.refreshRate == 60 then
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
    "${mkUserJs (
      fastfox
      // securefox
      // peskyfox
      // smoothfox
      // {
        "zen.theme.content-element-separation" = 1;
        "zen.glance.activation-method" = "ctrl";
        "zen.theme.color-prefs.use-workspace-colors" = false;
        "zen.theme.accent-color" = dark.fg0;
        "zen.welcome-screen.seen" = true;
        "zen.view.experimental-no-window-controls" = true;
        "zen.tabs.vertical.right-side" = true;

        "browser.uiCustomization.state" = ''
          {
            "placements": {
              "widget-overflow-fixed-list": [],
              "unified-extensions-area": [
                "dearrow_ajay_app-browser-action",
                "moz-addon-prod_7tv_app-browser-action",
                "sponsorblocker_ajay_app-browser-action",
                "ublock0_raymondhill_net-browser-action",
                "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action",
                "_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action",
                "addon_darkreader_org-browser-action",
                "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action",
                "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action",
                "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action",
                "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
              ],
              "nav-bar": [
                "back-button",
                "forward-button",
                "stop-reload-button",
                "customizableui-special-spring1",
                "vertical-spacer",
                "urlbar-container",
                "customizableui-special-spring2",
                "unified-extensions-button"
              ],
              "toolbar-menubar": [
                "menubar-items"
              ],
              "TabsToolbar": [
                "tabbrowser-tabs"
              ],
              "vertical-tabs": [],
              "PersonalToolbar": [
                "personal-bookmarks"
              ],
              "zen-sidebar-top-buttons": [],
              "zen-sidebar-foot-buttons": [
                "downloads-button",
                "zen-workspaces-button",
                "zen-create-new-button"
              ]
            },
            "seen": [
              "_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action",
              "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action",
              "addon_darkreader_org-browser-action",
              "ublock0_raymondhill_net-browser-action",
              "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action",
              "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action",
              "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action",
              "sponsorblocker_ajay_app-browser-action",
              "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action",
              "moz-addon-prod_7tv_app-browser-action",
              "dearrow_ajay_app-browser-action",
              "developer-button",
              "screenshot-button"
            ],
            "dirtyAreaCache": [
              "unified-extensions-area",
              "nav-bar",
              "vertical-tabs",
              "zen-sidebar-foot-buttons",
              "toolbar-menubar",
              "TabsToolbar",
              "PersonalToolbar"
            ],
            "currentVersion": 23,
            "newElementCount": 2
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
        "browser.display.background_color.dark" = dark.bg0;

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
        # "webgl.disabled" = true;

        # disable autoplay
        "media.autoplay.blocking_policy" = 2;

        # needed termfilechooser
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      }
    )}";
}
