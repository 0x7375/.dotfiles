{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) getExe getExe';
in
{
  imports = [
    ./hardware.nix
    ./options.nix
  ]
  ++ (lib.my.filesIn ./modules);

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys =
      let
        inherit (config.me) sshKeys;
      in
      [
        sshKeys.yugen
        sshKeys.kumo
      ];
  };

  vars.WINIT_X11_SCALE_FACTOR = "1.11";

  hardware.brillo.enable = true;
  services.udev.extraRules = # bash
    ''
      # Allow video group to change screen brightness
      ACTION=="add", \
      SUBSYSTEM=="backlight", \
      KERNEL=="amdgpu_bl0", \
      RUN+="${getExe' pkgs.coreutils "chgrp"} video /sys/class/backlight/%k/brightness", \
      RUN+="${getExe' pkgs.coreutils "chmod"} g+w /sys/class/backlight/%k/brightness"

      # Notifications on power plug/unplug
      ACTION=="change", \
      SUBSYSTEM=="power_supply", \
      ATTR{type}=="Mains", \
      ATTR{online}=="0", \
      ENV{DISPLAY}=":0", \
      ENV{XAUTHORITY}="/run/user/${toString config.me.uid}/Xauthority", \
      RUN+="${getExe' pkgs.su "su"} ${config.me.user} -c '${getExe pkgs.scripts.charging-notify} 0'"

      ACTION=="change", \
      SUBSYSTEM=="power_supply", \
      ATTR{type}=="Mains", \
      ATTR{online}=="1", \
      ENV{DISPLAY}=":0", \
      ENV{XAUTHORITY}="/run/user/${toString config.me.uid}/Xauthority", \
      RUN+="${getExe' pkgs.su "su"} ${config.me.user} -c '${getExe pkgs.scripts.charging-notify} 1'"
    '';

  programs.i3lock.enable = true;

  packages = with pkgs; [
    acpi
    scripts.idle-check
    scripts.lock
    scripts.powermenu
  ];

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  systemd.services.disable-lid-wakeup = {
    description = "Disable lid switch as wake source";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${getExe pkgs.bash} -c 'echo LID > /proc/acpi/wakeup'";
      RemainAfterExit = true;
    };
  };

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
