{ inputs, ... }:

{
  flake.modules.nixos.woz =
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
      nix.settings = {
        extra-substituters = [ "https://nixos-apple-silicon.cachix.org" ];
        extra-trusted-public-keys = [
          "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
        ];
      };

      imports = [
        inputs.apple-silicon.nixosModules.apple-silicon-support
      ];

      nix.settings = {
        cores = 4;
        max-jobs = 1;
      };

      boot.extraModprobeConfig = "options hid_apple swap_fn_leftctrl=1";

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

      tinted.files.".config/mango/config.conf".value = _: {
        switchbind = [
          "fold,spawn,${getExe pkgs.my.lock} lock-and-suspend"
        ];
        tap_to_click = 1;
        tap_and_drag = 0;
      };

      hj.xdg.config.files."noctalia/settings.toml".value = {
        idle = {
          behavior_order = [
            "screen-off"
            "lock-and-suspend"
          ];
          behavior = {
            screen-off = {
              command = "noctalia:dpms-off";
              resume_command = "noctalia:dpms-on";
              timeout = 300;
              enabled = true;
            };
            lock-and-suspend = {
              command = "noctalia:session lock-and-suspend";
              resume_command = "noctalia:dpms-on";
              timeout = 600;
              enabled = true;
            };
          };
        };
      };

      # force usb to disconnect/reconnect
      powerManagement.resumeCommands = ''
        ${getExe pkgs.unstable.tuxvdmtool} disconnect
      '';

      packages = with pkgs; [ acpi ];

      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandlePowerKey = "ignore";
      };

      system.stateVersion = "25.11";
    };
}
