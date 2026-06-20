{
  flake.modules.nixos.laptop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) getExe getExe';
    in
    {
      hardware.brillo.enable = true;
      services.udev.extraRules =
        # bash
        ''
          # Allow video group to change screen brightness
          ACTION=="add", \
          SUBSYSTEM=="backlight", \
          KERNEL=="amdgpu_bl0", \
          RUN+="${getExe' pkgs.coreutils "chgrp"} video /sys/class/backlight/%k/brightness", \
          RUN+="${getExe' pkgs.coreutils "chmod"} g+w /sys/class/backlight/%k/brightness"

          # Automatically lock when security key is unplugged
          ACTION=="remove",\
          SUBSYSTEM=="usb",\
          ENV{DEVTYPE}=="usb_interface",\
          ENV{INTERFACE}=="11/0/0",\
          ENV{PRODUCT}=="349e/24/100",\
          RUN+="${getExe pkgs.sudo} -u ${config.me.user} env XDG_RUNTIME_DIR=/run/user/${toString config.me.uid} ${getExe pkgs.my.lock} lock"
        '';

      services.upower.enable = true;

      packages = with pkgs; [ acpi ];

      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandlePowerKey = "ignore";
      };
    };
}
