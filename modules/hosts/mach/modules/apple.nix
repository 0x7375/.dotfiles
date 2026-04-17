{
  flake.darwin.mach =
    {
      pkgs,
      lib,
      ...
    }:
    lib.mkMerge [
      {
        # doc: https://github.com/mathiasbynens/dotfiles/blob/b7c7894e7bb2de5d60bfb9a2f5e46d01a61300ea/.macos
        system = {
          startup.chime = false;
          defaults = {
            hitoolbox.AppleFnUsageType = "Do Nothing";
            CustomSystemPreferences."com.apple.Accessibility".ReduceMotionEnabled = 1;
            menuExtraClock.Show24Hour = true;
            universalaccess = {
              reduceMotion = true;
              reduceTransparency = true;
            };
            LaunchServices.LSQuarantine = false;
            NSGlobalDomain = {
              AppleFontSmoothing = 0;
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

              ApplePressAndHoldEnabled = true;

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
              minimize-to-application = false;
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
              "com.apple.PowerChime" = {
                ChimeOnNoHardware = true;
              };
              "com.apple.Spotlight".MenuItemHidden = 1;
              NSGlobalDomain = {
                NSUserKeyEquivalents = {
                  Minimize = "";
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
              "com.apple.dock".no-bouncing = true;
            };
          };
        };
      }
      {
        packages = [
          pkgs.duti
        ];

        activation = # bash
          ''
            export PATH=${pkgs.duti}/bin:$PATH
            NVIM="org.nixos.nvim"

            duti -s info.sioyek.sioyek .pdf all

            duti -s $NVIM .txt all
            duti -s $NVIM .md all
            duti -s $NVIM .nix all
            duti -s $NVIM public.plain-text all
            duti -s $NVIM public.unix-executable all
          '';
      }
    ];
}
