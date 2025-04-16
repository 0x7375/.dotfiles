{
  lib,
  config,
  myLib,
  pkgs,
  ...
}:

{
  imports =
    [
      ./hardware.nix
      ./options.nix
    ]
    ++ (myLib.filesIn ../../nixos)
    ++ (myLib.filesIn ./nixos);

  networking.hostName = config.me.hostname;

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys =
      let
        inherit (myLib) ssh-keys;
      in
      [
        ssh-keys.yugen
        ssh-keys.kumo
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
      ENV{XAUTHORITY}="/run/user/${toString config.me.uid}/Xauthority", \
      RUN+="${pkgs.su}/bin/su ${config.me.user} -c '${pkgs.scripts.charging-notify}/bin/charging-notify 0'"

      ACTION=="change", \
      SUBSYSTEM=="power_supply", \
      ATTR{type}=="Mains", \
      ATTR{online}=="1", \
      ENV{DISPLAY}=":0", \
      ENV{XAUTHORITY}="/run/user/${toString config.me.uid}/Xauthority", \
      RUN+="${pkgs.su}/bin/su ${config.me.user} -c '${pkgs.scripts.charging-notify}/bin/charging-notify 1'"
    '';

  environment.systemPackages = with pkgs; [
    acpi
  ];

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

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
