{
  lib,
  system,
  myLib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      master = import inputs.nixpkgs-master {
        system = final.system;
        config.allowUnfree = true;
      };
      # stable = import inputs.nixpkgs-stable {
      #   system = final.system;
      #   config.allowUnfree = true;
      # };
      auto = import inputs.auto-update {
        system = final.system;
        config.allowUnfree = true;
      };

      #   nil = prev.nil.override (old: {
      #     rustPlatform = old.rustPlatform // {
      #       buildRustPackage = args: old.rustPlatform.buildRustPackage (args // rec {
      #         version = "2f3ed6348bbf1440fcd1ab0411271497a0fbbfa4";
      #         src = pkgs.fetchFromGitHub {
      #           owner = "oxalica";
      #           repo = "nil";
      #           rev = version;
      #           sha256 = "sha256-o4tqlTzi9kcVub167kTGXgCac9jM3kW4+v9MH/ue4Hk=";
      #         };
      #         cargoHash = "sha256-um8D8NO30BbKTTaiyJ8nURHW3cZlmdTC+a530lxKt3Q=";
      #       });
      #     };
      #   });

      # ente-auth = prev.callPackage ../derivations/ente-auth/package.nix { flutter324 = prev.flutter324; };

      # ente-auth = (import inputs.nixpkgs-master {
      #   system = final.system;
      #   config.allowUnfree = true;
      # }).ente-auth.overrideAttrs (old: {
      #   # patches = (old.patches or [ ]) ++ [
      #   #   (prev.fetchpatch {
      #   #     url = "https://github.com/ente-io/ente/commit/87f7d3a4843c98defcf0a14553d32ab76a7f6bfd.patch";
      #   #     sha256 = "04ym0kg81gj0rcvl50a7l16jkbqd5xfzj6jq45npg09wlq30n4hm";
      #   #   })
      #   # ];
      # });

      polybar =
        (prev.polybar.override {
          i3Support = true;
        }).overrideAttrs
          (old: {
            # change ellipsis on overflow from ... to ~
            postPatch = ''
              substituteInPlace include/drawtypes/label.hpp \
                --replace-fail "m_maxlen >= 3" "m_maxlen >= 1"
              substituteInPlace src/drawtypes/label.cpp \
                --replace-fail "m_maxlen - 3) + \"...\"" "m_maxlen - 1) + \"~\""
              substituteInPlace src/drawtypes/label.cpp \
                --replace-fail "maxlen < 3" "maxlen < 1"
            '';
          });

      # nh = prev.nh.overrideAttrs (old: {
      #   postPatch = ''
      #     substituteInPlace src/search.rs \
      #       --replace-fail "print_hyperlink!(position, format!(\"file://{nixpkgs_path}/{postion_trimmed}\"));" "print_hyperlink!(format!(\"https://github.com/NixOS/nixpkgs/blob/nixos-unstable/{postion_trimmed}\"), \"\");"
      #   '';
      # });

      # derivations
      fonts = {
        CartographCF = prev.callPackage ../derivations/fonts/CartographCF.nix { };
        InconsolataNF = prev.callPackage ../derivations/fonts/InconsolataNF.nix { };
      };

      firefox = inputs.auto-update.legacyPackages.${system}.firefox.override {
        extraPolicies = {
          Cookies = {
            Allow = [
              "https://brave.com"
              "https://reddit.com"
              "https://twitch.tv"
              "https://monkeytype.com"
              "https://openai.com"
              "https://chatgpt.com"
              "https://youtube.com"
              "https://google.com"
              "https://claude.ai"
              "https://deepseek.com"
            ];
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
            ];
          "3rdparty".Extensions = {
            "uBlock0@raymondhill.net".adminSettings = {
              userSettings = {
                uiAccentCustom = true;
                uiAccentCustom0 = myLib.palette.cyan;
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
              "userFilters" = (builtins.readFile ../assets/uBlockFilters.txt);
            };
          };
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          SearchSuggestEnabled = false;
        };
      };

      scripts =
        let
          scriptFiles = builtins.filter (f: builtins.match ".*\\.nix$" (toString f) != null) (
            myLib.filesIn ../scripts/home ++ myLib.filesIn ../scripts/nixos
          );
        in
        builtins.listToAttrs (
          map (path: {
            name = builtins.elemAt (builtins.match "([^.]+).*" (builtins.baseNameOf path)) 0;
            value = import path {
              inherit
                myLib
                config
                pkgs
                inputs
                ;
            };
          }) scriptFiles
        );
    })
  ];
}
