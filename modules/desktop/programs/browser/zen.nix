let
  profile = "nix";
  policies = lib: import ./_policies.nix lib;
  shortcuts = builtins.readFile ./zen-keyboard-shortcuts.json;
  js =
    refreshRate: lib:
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
    "${mkUserJs (
      fastfox
      // securefox
      // peskyfox
      // smoothfox
      // {
        "zen.theme.content-element-separation" = 1;
        "zen.glance.activation-method" = "ctrl";
        "zen.theme.color-prefs.use-workspace-colors" = false;
        # "zen.theme.accent-color" = dark.fg0;
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
        # "browser.display.background_color.dark" = dark.bg0;

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

        # show new tab button
        "zen.tabs.show-newtab-vertical" = false;

        # show traditional three dot menu on mac
        "zen.view.mac.show-three-dot-menu" = true;

        "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;

        # no popups ty
        "media.webspeech.synth.enabled" = false;
        "network.protocol-handler.external.mailto" = false;

        # force hardware acceleration
        "media.hardware-video-decoding.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      }
    )}";
  profiles = lib: isDarwin: {
    type = "copy";
    generator = lib.generators.toINI { };
    value = {
      Profile0 = {
        Name = profile;
        IsRelative = 1;
        Path = "${lib.optionalString isDarwin "Profiles/"}${profile}";
        Default = 1;
      };

      General = {
        StartWithLastProfile = 1;
        Version = 2;
      };
    }
    // lib.optionalAttrs isDarwin {
      "Install6ED35B3CA1B5D3AF" = {
        Default = "Profiles/${profile}";
        Locked = 1;
      };
    };
  };
  css = # css
    ''
      /* hide current workspace indicator */
      .zen-current-workspace-indicator {
        display: none !important;
      }

      /* remove separator above tabs */
      .pinned-tabs-container-separator {
          display: none !important;
      }

      /* add some padding above tabs */
      .zen-workspace-normal-tabs-section {
        padding-block-start: .5em !important;
      }

      /* disable animations */
      * {
        animation: none !important;
      }
    '';
in
{
  flake.shared.desktop = {
    # required for zen to load the custom profile
    vars.MOZ_LEGACY_PROFILES = "1";
  };

  flake.darwin.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (pkgs.stdenv) isDarwin;
    in
    {
      homebrew.casks = [ "zen" ];

      environment.etc."zen-policies.plist".text = lib.generators.toPlist { escape = true; } (
        (policies lib) // { EnterprisePoliciesEnabled = true; }
      );

      activation = ''
        cp -f "/etc/zen-policies.plist" "/Library/Preferences/app.zen-browser.zen.plist"
      '';

      hj.files."Library/Application Support/zen-browser/Policies/Managed/policies.json".source =
        "/etc/zen-policies.plist";

      hj.files."Library/Application Support/zen/installs.ini" = {
        type = "copy";
        generator = lib.generators.toINI { };
        value = {
          "6ED35B3CA1B5D3AF" = {
            Default = "Profiles/${profile}";
            Locked = 1;
          };
        };
      };

      hj.files."Library/Application Support/zen/profiles.ini" = profiles lib isDarwin;
      hj.files."Library/Application Support/zen/Profiles/${profile}/chrome/userChrome.css".text = css;
      hj.files."Library/Application Support/zen/Profiles/${profile}/zen-keyboard-shortcuts.json".text =
        shortcuts;
      hj.files."Library/Application Support/zen/Profiles/${profile}/user.js".text =
        js config.me.desktop.refreshRate lib;
    };

  flake.nixos.desktop =
    {
      inputs,
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (pkgs.stdenv) isDarwin;
    in
    {
      # for hardware acceleration
      vars.MOZ_DISABLE_RDD_SANDBOX = "1";

      packages = [
        (pkgs.wrapFirefox
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
          {
            pname = "zen-browser";
            extraPolicies = policies lib;
          }
        )
      ];

      hj.files.".zen/profiles.ini" = profiles lib isDarwin;
      hj.files.".zen/${profile}/chrome/userChrome.css".text = css;
      hj.files.".zen/${profile}/zen-keyboard-shortcuts.json".text = shortcuts;
      hj.files.".zen/${profile}/user.js".text = js config.me.desktop.refreshRate lib;
      # TODO declarative zen mods
      # hj.files.".zen/${profile}/zen-themes.json".text = (builtins.readFile ./zen-themes.json);
    };
}
