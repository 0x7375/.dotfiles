lib: {
  Cookies = {
    Allow = [
      "https://reddit.com"
      "https://twitch.tv"
      "https://monkeytype.com"
      "https://youtube.com"
      "https://claude.ai"
      "https://gemini.google.com"
      "https://brave.com"
      "https://keybr.com"
      "https://vault.bitwarden.com"
    ];
  };
  SearchEngines.Default = "Google";
  ExtensionSettings =
    with builtins;
    let
      extension = shortId: uuid: {
        name = uuid;
        value = {
          install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
          installation_mode = "normal_installed";
        };
      };
    in
    listToAttrs [
      (extension "ublock-origin" "uBlock0@raymondhill.net")
      (extension "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}")
      (extension "vimium-ff" "{d7742d87-e61d-4b78-b8a1-b469842139fa}")
      (extension "buster-captcha-solver" "{e58d3966-3d76-4cd9-8552-1582fbc800c1}")
      (extension "sponsorblock" "sponsorBlocker@ajay.app")
      (extension "remove-youtube-s-suggestions" "{21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26}")
      (extension "dearrow" "deArrow@ajay.app")
      (extension "styl-us" "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}")
    ]
    // {
      "moz-addon-prod@7tv.app" = {
        install_url = "https://extension.7tv.gg/v3.0.9/ext.xpi";
        installation_mode = "normal_installed";
      };
    };
  "3rdparty".Extensions = {
    "uBlock0@raymondhill.net".adminSettings = {
      userSettings = {
        uiAccentCustom = true;
        uiAccentCustom0 = "#98971a";
        cloudStorageEnabled = lib.mkForce false;
        importedLists = [ ];
        advancedUserEnabled = true;
        firewallPaneMinimized = false;
      };
      selectedFilterLists = [
        "user-filters"
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-quick-fixes"
        "ublock-unbreak"
        "easylist"
        "adguard-generic"
        "adguard-mobile"
        "easyprivacy"
        "adguard-spyware"
        "adguard-spyware-url"
        "block-lan"
        "urlhaus-1"
        "curben-phishing"
        "plowe-0"
        "dpollock-0"
        "fanboy-cookiemonster"
        "ublock-cookies-easylist"
        "adguard-cookies"
        "ublock-cookies-adguard"
        "fanboy-social"
        "adguard-social"
        "fanboy-thirdparty_social"
        "easylist-chat"
        "easylist-newsletters"
        "easylist-notifications"
        "easylist-annoyances"
        "adguard-mobile-app-banners"
        "adguard-other-annoyances"
        "adguard-popup-overlays"
        "adguard-widgets"
        "ublock-annoyances"
        "FRA-0"
      ];
      hiddenSettings = {
        userResourcesLocation = "https://github.com/pixeltris/TwitchAdSolutions/raw/master/vaft/vaft-ublock-origin.js";
      };
      "userFilters" = builtins.readFile ./uBlockFilters.txt;
    };
  };
  DontCheckDefaultBrowser = true;
  NoDefaultBookmarks = true;
  SearchSuggestEnabled = false;
  DisableTelemetry = true;
  DisableAppUpdate = true;
}
