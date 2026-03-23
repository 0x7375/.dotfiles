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

  hardware.graphics.enable = true;

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
      ENV{WAYLAND_DISPLAY}="wayland-1", \
      ENV{XDG_RUNTIME_DIR}="/run/user/${toString config.me.uid}", \
      RUN+="${getExe' pkgs.su "su"} ${config.me.user} -c '${getExe pkgs.my.charging-notify} 0'"

      ACTION=="change", \
      SUBSYSTEM=="power_supply", \
      ATTR{type}=="Mains", \
      ATTR{online}=="1", \
      ENV{WAYLAND_DISPLAY}="wayland-1", \
      ENV{XDG_RUNTIME_DIR}="/run/user/${toString config.me.uid}", \
      RUN+="${getExe' pkgs.su "su"} ${config.me.user} -c '${getExe pkgs.my.charging-notify} 1'"

      # Automatically lock when security key is unplugged
      ACTION=="remove",\
      SUBSYSTEM=="usb",\
      ENV{DEVTYPE}=="usb_interface",\
      ENV{INTERFACE}=="11/0/0",\
      ENV{PRODUCT}=="349e/24/100",\
      ENV{WAYLAND_DISPLAY}="wayland-1", \
      ENV{XDG_RUNTIME_DIR}="/run/user/${toString config.me.uid}", \
      RUN+="${lib.getExe' pkgs.xorg.xset "xset"} s activate"
    '';

  packages = with pkgs; [ acpi ];

  services.acpid = {
    enable = true;
    handlers.lid = {
      event = "button/lid LID close";
      action =
        # bash
        ''
          if ${lib.getExe' pkgs.procps "pgrep"} -x hyprlock > /dev/null; then
            systemctl hibernate
          fi
        '';
    };
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

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

  services.hypridle.enable = true;

  hj.xdg.config.files."hypr/hypridle.conf".text = ''
    general {
      before_sleep_cmd = ${lib.getExe pkgs.my.lock}
    }

    listener {
      timeout = 600
      on-timeout = ${lib.getExe pkgs.my.lock}
    }
  '';

  security.pam.services.hyprlock = {
    u2fAuth = true;
    unixAuth = false;
  };

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
