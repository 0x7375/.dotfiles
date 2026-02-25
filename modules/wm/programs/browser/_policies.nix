{ lib, config, ... }:

{
  Cookies = {
    Allow = [
      "https://reddit.com"
      "https://twitch.tv"
      "https://monkeytype.com"
      "https://youtube.com"
      "https://claude.ai"
      "https://keybr.com"
    ];
  };
  SearchEngines = {
    Add = [
      {
        Name = "Google";
        URLTemplate = "https://google.com/search?q={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/google.com.ico";
        Alias = "!g";
      }
      {
        Name = "Google Images";
        URLTemplate = "https://google.com/search?q={searchTerms}&tbm=isch";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/google.com.ico";
        Alias = "!gi";
      }
      {
        Name = "Startpage";
        URLTemplate = "https://www.startpage.com/do/dsearch?prfe=d7a6edf2bdae7d159fd3c7281470fb1b1611b9ebc58099d433766aab83750a24485b18c6615e9979c5ef4f823efb2326568630359a4cfaca9f87b8eda4b78324a831f096405c6b39160f84ca&query={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/startpage.com.ico";
        Alias = "!s";
      }
      {
        Name = "Brave";
        URLTemplate = "https://search.brave.com/search?q={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/brave.com.ico";
        Alias = "!b";
      }
      {
        Name = "Brave Images";
        URLTemplate = "https://search.brave.com/images?q={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/brave.com.ico";
        Alias = "!bi";
      }
      {
        Name = "Nix Packages";
        URLTemplate = "https://mynixos.com/search?q=package+{searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/mynixos.com.ico";
        Alias = "!p";
      }
      {
        Name = "Nix Options";
        URLTemplate = "https://mynixos.com/search?q=option+{searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/mynixos.com.ico";
        Alias = "!o";
      }
      {
        Name = "Nix Functions";
        URLTemplate = "https://noogle.dev/q?term={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/noogle.dev.ico";
        Alias = "!n";
      }
      {
        Name = "Nixpkgs history";
        URLTemplate = "https://history.nix-packages.com/search?search={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/mynixos.com.ico";
        Alias = "!u";
      }
      {
        Name = "Youtube";
        URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/youtube.com.ico";
        Alias = "!y";
      }
      {
        Name = "Github";
        URLTemplate = "https://github.com/search?type=code&q={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/github.com.ico";
        Alias = "!h";
      }
      {
        Name = "Wikipedia";
        URLTemplate = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/wikipedia.org.ico";
        Alias = "!w";
      }
      {
        Name = "Conjugaison";
        URLTemplate = "https://conjugaison.bescherelle.com/verbes/{searchTerms}";
        Method = "GET";
        IconURL = "https://icons.duckduckgo.com/ip3/conjugaison.bescherelle.com.ico";
        Alias = "!c";
      }
    ];
    Default = "Google";
    PreventInstalls = true;
  };
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
        uiAccentCustom0 = config.me.palette.dark.cyan;
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
