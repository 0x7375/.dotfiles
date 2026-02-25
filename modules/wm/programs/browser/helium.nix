{
  pkgs,
  config,
  lib,
  ...
}:

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

  policies = {
    DefaultCookiesSetting = 4;
    CookiesAllowedForUrls = [
      "https://reddit.com"
      "https://twitch.tv"
      "https://monkeytype.com"
      "https://youtube.com"
      "https://claude.ai"
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

    WebAppInstallForceList = [
      {
        create_desktop_shortcut = true;
        default_launch_container = "window";
        custom_name = "Bitwarden";
        url = "https://vault.bitwarden.com";
      }
    ];

    "3rdparty".extensions = {
      ${extensions.ublock}.adminSettings = builtins.toJSON {
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
  };
in
{
  packages = [
    # patched for compatibility with nixos module, add cli flags
    (pkgs.nur.repos.Ev357.helium.overrideAttrs (old: {
      buildCommand =
        let
          bwrapPath = builtins.head (builtins.match ".*ln -s ([^ ]+) [$]out/bin/helium.*" old.buildCommand);
          flags = [
            "--enable-features=HeliumMiddleClickAutoscroll"
            "--no-first-run"
          ];
        in
        ''
          mkdir -p $out/bin
          cp ${bwrapPath} $out/bin/helium
          sed -i 's|--tmpfs /etc|--tmpfs /etc --ro-bind /etc/chromium /etc/chromium|' $out/bin/helium

          # enable autoscroll
          sed -i 's|-container-init "\$@"|-container-init ${builtins.concatStringsSep " " flags} "\$@"|' $out/bin/helium
        ''
        +
          builtins.replaceStrings [ "mkdir -p $out/bin\nln -s ${bwrapPath} $out/bin/helium\n" ] [ "" ]
            old.buildCommand;
    }))
  ];

  programs.chromium = {
    enable = true;
    extensions = lib.attrValues extensions;
    extraOpts = policies;
  };
}
