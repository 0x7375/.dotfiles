{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/default.nix
    ../../modules/custom/me.nix
    ../../modules/custom/tinted.nix
    ../../modules/core/programs/git.nix
    ../../modules/core/system/nixpkgs.nix
    ../../modules/core/secrets/default.nix
    ../../modules/core/programs/tmux
    ../../modules/core/programs/fzf.nix
    ../../modules/core/programs/neovim.nix
    ../../modules/core/programs/bash.nix
    ../../modules/core/programs/nix-search
    ../../modules/core/programs/direnv.nix
    ../../modules/core/programs/lf
    ../../modules/core/xdg/home-cleanup.nix
    ../../modules/core/environment/packages.nix
    ../../modules/core/environment/aliases.nix
    ../../modules/core/environment/variables.nix
    ../../modules/wm/pkgs.nix
    ../../modules/wm/theme/tinted.nix
    ../../modules/wm/x11/alacritty.nix
    ./options.nix
    (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" config.me.user ])
    (lib.mkAliasOptionModule [ "activation" ] [ "system" "activationScripts" "activation" "text" ])
  ]
  ++ (lib.my.filesIn ./modules)
  ++ (lib.my.filesIn ../../modules/wm/programs/browser)
  ++ (lib.my.filesIn ../../modules/core/zsh);

  options = {
    systemd = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = {
    activation = ''
      mkdir -p /usr/local/etc/wireguard
      ln -sfn /etc/wireguard/ /usr/local/etc/wireguard
    '';

    unfree-packages = [
      "1password"
      "1password-cli"
    ];

    nix = {
      extraOptions = ''
        warn-dirty = false
        trusted-users = root ${config.me.user}
      '';
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      channel.enable = false;
      optimise.automatic = true;
      settings = {
        flake-registry = "";
        experimental-features = [
          "nix-command flakes"
          "pipe-operators"
        ];
        use-xdg-base-directories = true;
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      };
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        stable.flake = inputs.nixpkgs-stable;
        n.flake = inputs.nixpkgs;
        t = {
          from.type = "indirect";
          from.id = "tmpl";
          to.type = "git";
          to.url = "https://codeberg.org/0x7E/templates";
        };
      };
    };

    homebrew = {
      enable = true;
      brews = [
        "syncthing"
      ];
      casks = [
        "middleclick"
        "discord"
        "alacritty"
        "signal"
      ];
    };

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

    packages = with pkgs; [
      python3
      nixd
      nixpkgs-fmt
      deno
      nodejs
      pear-desktop
      ripgrep
      tree-sitter
      wireguard-tools
      scripts.nlink
      scripts.nd
      cowsay
      dark-mode-notify
    ];

    programs._1password.enable = true;

    hjem.users.ayko.directory = "/Users/ayko";

    system.defaults = {
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {

        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.keyboard.fnState" = true;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;

        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.001;

        InitialKeyRepeat = 13;
        KeyRepeat = 2;
      };
      dock = {
        autohide = true;
        show-recents = false;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        expose-animation-duration = 0.1;
        expose-group-apps = true;
        autohide-delay = 1000.0;
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
      };
      CustomUserPreferences = {
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0;
          StandardHideDesktopIcons = 0;
        };
        "com.apple.screencapture" = {
          location = "~/Pictures/screenshots/macOS";
          type = "png";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.controlcenter" = {
          BatteryShowPercentage = true;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.finder" = {
          NewWindowTargetPath = "file://${config.me.home}/";
          NewWindowTarget = "PfHm";
          FXDefaultSearchScope = "SCcf";
        };
      };
    };

    # TODO: fix tmux-sshr not using FZF_DEFAULT_OPTS
    environment.etc."zshenv".text = lib.mkAfter ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      if [ -z "''${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
        . ${config.system.build.setEnvironment}
      fi

      export PATH=/run/current-system/sw/bin:/usr/bin:/bin:$PATH
    '';

    hj.xdg.config.files."zsh/.zshenv".text = config.environment.etc."zshenv".text;

    # TODO: merge rebuild logic
    hj.xdg.config.files."zsh/.zshrc".text = lib.mkBefore ''
      ${config.environment.shellInit}
      alias nd="sudo darwin-rebuild switch --flake $FLAKE"
    '';

    launchd.user.agents.theme-switcher = {
      serviceConfig = {
        ProgramArguments = [
          "${lib.getExe pkgs.dark-mode-notify}"
          "${lib.getExe pkgs.scripts.swap-theme}"
          "sync"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/theme-switcher.out";
        StandardErrorPath = "/tmp/theme-switcher.err";
      };
    };

    vars.LANG = "en_US.UTF-8";
    nixpkgs.hostPlatform = "aarch64-darwin";
    system.stateVersion = 6;
  };
}
