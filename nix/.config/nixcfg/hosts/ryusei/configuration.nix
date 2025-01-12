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

  services.tlp.enable = true;

  services.libinput.touchpad = {
    naturalScrolling = true;
    tapping = true;
    tappingDragLock = false;
    disableWhileTyping = true;
  };

  age.secrets.syncthing-ryusei-cert = {
    file = "${secrets}/syncthing-ryusei-cert.age";
    owner = config.me.user;
  };

  age.secrets.syncthing-ryusei-key = {
    file = "${secrets}/syncthing-ryusei-key.age";
    owner = config.me.user;
  };

  services.syncthing = lib.mkIf config.me.secrets.enable {
    key = "${config.age.secrets.syncthing-ryusei-key.path}";
    cert = "${config.age.secrets.syncthing-ryusei-cert.path}";
  };

  age.secrets.laptop-vpn-pk = {
    file = "${secrets}/laptop-vpn-pk.age";
    owner = config.me.user;
  };

  # networking.wg-quick.interfaces."homevpn" = {
  #   autostart = false;
  #   privateKeyFile = config.age.secrets.laptop-vpn-pk.path;
  #   address = [ "10.0.0.2/24" ];
  #   listenPort = 51820;
  #
  #   peers = [
  #     {
  #       allowedIPs = [
  #         "10.0.0.0/24"
  #         "192.168.1.0/24"
  #       ];
  #       publicKey = "serverPk";
  #       endpoint = ":51820";
  #     }
  #   ];
  # };

  # do not change   
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
