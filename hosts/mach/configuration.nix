{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./options.nix
    (lib.mkAliasOptionModule [ "activation" ] [ "system" "activationScripts" "postActivation" "text" ])
  ]
  ++ (lib.my.filesIn ./modules)
  ++ (lib.my.filesIn ../../modules);

  activation = ''
    # disable macos quarantine
    spctl --master-disable > /dev/null 2>&1 || true
  '';

  # "known to corrupt the Nix Store"
  nix.settings.auto-optimise-store = lib.mkForce false;

  unfree-packages = [
    "1password"
    "1password-cli"
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = config.me.user;
  };

  homebrew = {
    enable = true;
    brews = [
      "choose-gui"
    ];
    casks = [
      "1password@beta"
      "ente-auth"
      "jellyfin-media-player"
      "karabiner-elements"
      "middleclick"
      "signal"
      "font-terminess-ttf-nerd-font"
      "raycast"
      "steam"
    ];
    onActivation = {
      cleanup = "zap";
      extraFlags = [ "--quiet" ];
    };
  };

  packages = with pkgs; [
    vesktop
    syncthing
    mas
    pear-desktop
    wireguard-tools
    dark-mode-notify

    (pkgs.stdenv.mkDerivation rec {
      pname = "kdeconnect-nightly";
      version = "5855";

      src = pkgs.fetchurl {
        url = "https://origin.cdn.kde.org/ci-builds/network/kdeconnect-kde/master/macos-arm64/kdeconnect-kde-master-${version}-macos-clang-arm64.dmg";
        hash = "sha256-aCPTooLM9hJ7hZrXzl3jfaQS7xOgXd2L87n/Qs1+YSY=";
      };

      nativeBuildInputs = [ pkgs.undmg ];

      sourceRoot = ".";

      installPhase = ''
        mkdir -p $out/Applications
        cp -r *.app $out/Applications
      '';
    })
  ];

  hj.xdg.config.files."karabiner/karabiner.json".source = "${
    inputs.karabiner-ts.packages.${pkgs.stdenv.hostPlatform.system}.default
  }/karabiner.json";

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.etc."pam.d/sudo_local".text = ''
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    auth       sufficient     pam_tid.so
  '';

  users.users.${config.me.user} = {
    home = config.me.home;
    openssh.authorizedKeys.keys =
      with config.me.hosts;
      map (h: h.sshPublicKey) [
        naitoh
        cray
      ];
  };

  programs._1password.enable = true;

  networking.applicationFirewall = {
    enable = true;
    allowSigned = true;
    allowSignedApp = true;
    enableStealthMode = true;
  };

  # doc: https://github.com/mathiasbynens/dotfiles/blob/b7c7894e7bb2de5d60bfb9a2f5e46d01a61300ea/.macos
  system = {
    startup.chime = false;
    defaults = {
      menuExtraClock.Show24Hour = true;
      universalaccess = {
        reduceMotion = true;
        reduceTransparency = true;
      };
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.keyboard.fnState" = true;
        "com.apple.mouse.tapBehavior" = 1;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
        _HIHideMenuBar = true;
        AppleKeyboardUIMode = 3;
        NSWindowShouldDragOnGesture = true;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;

        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.001;

        ApplePressAndHoldEnabled = false;

        InitialKeyRepeat = 13;
        KeyRepeat = 2;

        AppleShowAllExtensions = true;
      };
      dock = {
        autohide = true;
        static-only = true;
        show-recents = false;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        expose-animation-duration = 0.1;
        expose-group-apps = true;
        autohide-delay = 1000.0;
        launchanim = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXRemoveOldTrashItems = true;
      };
      CustomUserPreferences = {
        "com.apple.Spotlight".MenuItemHidden = 1;
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "163" = {
              # Set 'Option + N' for Show Notification Center
              enabled = true;
              value = {
                parameters = [
                  110
                  45
                  524288
                ];
                type = "standard";
              };
            };
          };
        };
        NSGlobalDomain = {
          NSUserKeyEquivalents = {
            Minimize = "@~^\\Uf70f";
          };
          "com.apple.mouse.linear" = true;
        };
        ".GlobalPreferences" = {
          AppleShowAllFiles = true;
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0;
          StandardHideDesktopIcons = 0;
        };
        "com.apple.screencapture" = {
          type = "png";
          location = "~/Pictures/screenshots/macOS";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.controlcenter".BatteryShowPercentage = true;
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.finder" = {
          DisableAllAnimations = true;
          WarnOnEmptyTrash = false;
          NewWindowTargetPath = "file://$HOME/";
          NewWindowTarget = "PfHm";
          FXDefaultSearchScope = "SCcf";
          _FXSortFoldersFirst = true;
        };
      };
    };
  };

  # TODO: fix tmux-sshr not using FZF_DEFAULT_OPTS
  environment.etc.zshenv.text = lib.mkAfter ''
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi

    if [ -z "''${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
      . ${config.system.build.setEnvironment}
    fi

    export PATH=/run/current-system/sw/bin:/usr/bin:/bin:$PATH
  '';

  hj.xdg.config.files."zsh/.zshenv".text = config.environment.etc.zshenv.text;

  hj.xdg.config.files."zsh/.zshrc".text = lib.mkBefore ''
    ${config.environment.shellInit}
  '';

  launchd.user.agents.theme-switcher = lib.my.mkLaunchdAgent {
    name = "theme-switcher";
    command = "${lib.getExe pkgs.dark-mode-notify} ${lib.getExe pkgs.my.swap-theme} sync";
  };

  launchd.user.agents.syncthing = lib.my.mkLaunchdAgent {
    name = "syncthing";
    command = "${lib.getExe pkgs.syncthing} --no-browser --no-restart";
    background = true;
  };

  hj.files.".hushlogin".text = "";

  vars.LANG = "en_US.UTF-8";
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
}
