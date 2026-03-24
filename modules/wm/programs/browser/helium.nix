let
  extensions = {
    ublock = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
    kagiTranslate = "alblebhaoakdgapamjdifdfnaicpnklm";
    stylus = "clngdbkpkpeebahjckkjfobafhncgmne";
    vimium = "dbepggeogbaibhgnhhndojpepiihcmeb";
    bitwarden = "nngceckbapebfimnlniiiahkandclblb";
    removeYoutubeSuggestions = "cdhdichomdnlaadbndgmagohccgpejae";
    sponsorBlock = "mnjggcdmjocbbbhaepdhchncahnbgone";
    deArrow = "enamippconapkdmgfgjchkhakpfinmaj";
    detachTab = "jalaajddhemiiilfhmenogfbpkbgglkk";
    captchaBuster = "mpbjkejclgfgadiemmefgebjfooflfhl";
  };

  flags = [
    "--enable-features=HeliumMiddleClickAutoscroll"
    "--no-first-run"
    "--enable-wayland-ime=true"
  ];

  policies =
    lib:
    let
      mkDisabledPermissions = perms: lib.genAttrs (map (p: "Default${p}Setting") perms) (_: 2);
    in
    {
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "Brave";
      DefaultSearchProviderSearchURL = "https://search.brave.com/search?q={searchTerms}";
      DefaultSearchProviderSuggestURL = "https://search.brave.com/api/suggest?q={searchTerms}";
      DefaultSearchProviderIconURL = "https://search.brave.com/favicon.ico";
      DefaultSearchProviderNewTabURL = "https://search.brave.com/";

      DefaultCookiesSetting = 4;

      CookiesAllowedForUrls = [
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
      ClearBrowsingDataOnExitList = [
        "cached_images_and_files"
        "download_history"
      ];

      SearchSuggestEnabled = false;

      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;

      DnsOverHttpsMode = "off";
      BlockThirdPartyCookies = true;
      HttpsOnlyMode = "force_enabled";
      SSLErrorOverrideAllowed = false;
      MetricsReportingEnabled = false;
      SafeBrowsingExtendedReportingEnabled = false;
      UrlKeyedAnonymizedDataCollectionEnabled = false;

      BackgroundModeEnabled = true;
      SpellCheckServiceEnabled = false;
      NewTabPageLocation = "about:blank";
      RestoreOnStartup = 1;
      AutoplayAllowed = false;

      ExtensionInstallSources = [
        "https://github.com/*"
        "https://raw.githubusercontent.com/*"
        "https://greasyfork.org/*"
        "https://update.greasyfork.org/*"
      ];

      "3rdparty".extensions = {
        ${extensions.ublock}.adminSettings = builtins.toJSON {
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
    }
    // mkDisabledPermissions [
      "Notifications"
      "Geolocation"
      "Cameras"
      "Microphone"
      "Popups"
    ];
in
{
  flake.shared.wm =
    {
      pkgs,
      ...
    }:
    let
      overlay = final: prev: {
        helium = pkgs.nur.repos.forkprince.helium-nightly.overrideAttrs (
          old:
          if (!pkgs.stdenv.isDarwin) then
            {
              buildCommand =
                let
                  bwrapPath = builtins.head (builtins.match ".*ln -s ([^ ]+) [$]out/bin/helium.*" old.buildCommand);
                in
                ''
                  mkdir -p $out/bin
                  cp ${bwrapPath} $out/bin/helium
                  sed -i 's|--tmpfs /etc|--tmpfs /etc --ro-bind /etc/chromium /etc/chromium|' $out/bin/helium
                  sed -i 's|-container-init "\$@"|-container-init ${builtins.concatStringsSep " " flags} "\$@"|' $out/bin/helium
                ''
                +
                  builtins.replaceStrings [ "mkdir -p $out/bin\nln -s ${bwrapPath} $out/bin/helium\n" ] [ "" ]
                    old.buildCommand;
            }
          else
            { }
        );
      };
    in
    {
      nixpkgs.overlays = [ overlay ];

      packages = [ pkgs.helium ];
    };

  flake.nixos.wm =
    { lib, ... }:
    {
      programs.chromium = {
        enable = true;
        extensions = lib.attrValues extensions;
        extraOpts = policies lib;
      };
    };

  flake.darwin.wm =
    {
      lib,
      pkgs,
      ...
    }:
    {
      activation =
        let
          managedPlist = pkgs.writeText "net.imput.helium.plist" (
            lib.generators.toPlist { escape = true; } (policies lib)
          );
        in
        ''
          install -d -m 0755 "/Library/Managed Preferences"
          install -m 0644 ${managedPlist} "/Library/Managed Preferences/net.imput.helium.plist"
        '';
    };
}
