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
    _7tv = "ammjkodgmmoknidbanneddgankgfejfh";
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
      DefaultSearchProviderName = "Startpage";
      DefaultSearchProviderSearchURL = "https://startpage.com/do/dsearch?prfe=d7a6edf2bdae7d159fd3c7281470fb1b1611b9ebc58099d433766aab83750a24485b18c6615e9979c5ef4f823efb2326568630359a4cfaca9f87b8eda4b78324a831f096405c6b39160f84ca&query={searchTerms}";
      DefaultSearchProviderIconURL = "https://startpage.com/favicon.ico";
      DefaultSearchProviderNewTabURL = "https://startpage.com/";

      DefaultCookiesSetting = 4;

      CookiesAllowedForUrls = [
        "https://reddit.com"
        "https://twitch.tv"
        "https://monkeytype.com"
        "https://youtube.com"
        "https://keybr.com"
        "https://vault.bitwarden.com"

        "https://claude.ai"
        "https://gemini.google.com"
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
        "https://clients2.google.com/service/update2/crx"
        "https://chrome.google.com/webstore/*"
        "https://clients2.9oo91e.qjz9zk/service/update2/crx"
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
  flake.modules.generic.desktop =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: _: {
          helium = final.nur.repos.forkprince.helium-nightly.overrideAttrs (
            old:
            if (!final.stdenv.isDarwin) then
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
        })
      ];

      packages = [ pkgs.helium ];
    };

  flake.modules.nixos.desktop =
    { lib, ... }:
    {
      programs.chromium = {
        enable = true;
        extensions = lib.attrValues extensions;
        extraOpts = policies lib;
      };
    };

  flake.modules.darwin.desktop =
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
          install -d -m 0755 "/Library/Preferences"
          install -m 0644 ${managedPlist} "/Library/Preferences/net.imput.helium.plist"
        '';
    };
}
