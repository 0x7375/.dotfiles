{
  secrets,
  lib,
  config,
  myLib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../nixos
    ./options.nix
  ] ++ (myLib.filesIn ./nixos);

  networking.hostName = config.me.hostname;

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53 yugen"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcGpmfziJoYbPbfdZi/REVStrNgl+F8lwVf1t2oLdaZ kumo"
    ];
  };

  hardware.brillo.enable = true;

  services.udev.extraRules = # bash
    ''
      # Allow video group to change screen brightness
      SUBSYSTEM=="backlight", \
      ACTION=="add", \
      KERNEL=="amdgpu_bl0", \
      RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", \
      RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"

      # Notifications on power plug/unplug
      ACTION=="change", \
      SUBSYSTEM=="power_supply", \
      ATTR{type}=="Mains", \
      ATTR{online}=="0", \
      ENV{DISPLAY}=":0", \
      ENV{XAUTHORITY}="/home/${config.me.user}/.Xauthority" \
      RUN+="${pkgs.su}/bin/su ${config.me.user} -c '${pkgs.scripts.charging-notify}/bin/charging-notify 0'"

      ACTION=="change", \
      SUBSYSTEM=="power_supply", \
      ATTR{type}=="Mains", \
      ATTR{online}=="1", \
      ENV{DISPLAY}=":0", \
      ENV{XAUTHORITY}="/home/${config.me.user}/.Xauthority" \
      RUN+="${pkgs.su}/bin/su ${config.me.user} -c '${pkgs.scripts.charging-notify}/bin/charging-notify 1'"
    '';

  environment.systemPackages = with pkgs; [
    acpi
    (where-is-my-sddm-theme.override {
      variants = [ "qt5" ];
      themeConfig.General = {
        hideCursor = true;
        passwordCursorColor = myLib.palette.fg0;
        passwordTextColor = myLib.palette.fg0;
      };
    })
    wine
    winetricks
  ];

  services.displayManager = {
    ly.enable = lib.mkForce false;
    sddm = {
      enable = true;
      theme = "where_is_my_sddm_theme_qt5";
      extraPackages = with pkgs; [
        libsForQt5.qt5.qtgraphicaleffects
      ];
      settings = {
        Autologin = {
          Session = "none+i3";
          User = config.me.user;
        };
      };
    };
    autoLogin = {
      enable = true;
      user = config.me.user;
    };
  };

  environment.variables = {
    WINIT_X11_SCALE_FACTOR = "1.20"; # giga zoom on alacritty otherwise
  };

  services.logind.lidSwitch = "ignore";

  services.auto-cpufreq.enable = true;

  services.libinput.touchpad = {
    naturalScrolling = true;
    tapping = true;
    tappingDragLock = false;
    disableWhileTyping = true;
  };

  sops.secrets."ryusei/syncthing/cert" = {
    owner = config.me.user;
  };

  sops.secrets."ryusei/syncthing/key" = {
    owner = config.me.user;
  };

  services.syncthing = lib.mkIf config.me.secrets.enable {
    key = "${config.sops.secrets."ryusei/syncthing/key".path}";
    cert = "${config.sops.secrets."ryusei/syncthing/cert".path}";
  };

  sops.secrets."ryusei/laptop_vpn_pk" = {
    owner = config.me.user;
  };

  sops.templates."home-vpn-laptop.conf".content = ''
    [Interface]
    Address = 10.0.0.2/24
    PrivateKey = ${config.sops.placeholder."ryusei/laptop_vpn_pk"}

    [Peer]
    PublicKey = PpCxUOTz7Heh3B29OnI3XNZAKJ8abUETMzFNj3gpTyo=
    PresharedKey = ${config.sops.placeholder."laptop_vpn_psk"}
    AllowedIPs = 10.0.0.0/24,192.168.1.0/24
    Endpoint = ${config.sops.placeholder.server_vpn_endpoint}
  '';

  networking.wg-quick.interfaces.home = {
    autostart = false;
    configFile = config.sops.templates."home-vpn-laptop.conf".path;
  };

  # until systemd is updated in nixpkgs: https://github.com/systemd/systemd/issues/34304#issuecomment-2550498883
  # https://github.com/systemd/systemd/commits/6013dee98d6543ac290a2938c4ec8494e26531ab/
  # https://www.nixhub.io/packages/systemd
  systemd.package = pkgs.systemd.overrideAttrs (old: {
    patches = old.patches ++ [
      (pkgs.fetchurl {
        url = "https://github.com/wrvsrx/systemd/compare/tag_fix-hibernate-resume%5E...tag_fix-hibernate-resume.patch";
        hash = "sha256-Z784xysVUOYXCoTYJDRb3ppGiR8CgwY5CNV8jJSLOXU=";
      })
    ];
  });

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
