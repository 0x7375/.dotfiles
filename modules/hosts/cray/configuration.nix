{
  flake.modules.nixos.cray = { pkgs, lib, ... }: {
    systemd.coredump.enable = lib.mkForce true;

    boot.supportedFilesystems = [ "ntfs" ];

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    vars = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    services.xserver.videoDrivers = [ "nvidia" ];
    unfree-packages = [
      "nvidia-x11"
      "nvidia-settings"
    ];

    nix.settings = {
      cores = 5;
      max-jobs = 4;
    };

    tinted.files.".config/mango/config.conf".value.mouse_accel_profile = "1";

    time.hardwareClockInLocalTime = true;

    tinted.files.".config/mango/config.conf".value.exec-once = [
      "mmsg dispatch viewcrossmon,5,HDMI-A-1 && mmsg dispatch viewcrossmon,1,HDMI-A-2"
    ];

    hj.xdg.config.files."noctalia/settings.toml".value.shell.session.actions = [
      (
        let
          switch-to-windows = pkgs.writeShellApplication {
            name = "switch-to-windows";
            text = ''
              ENTRY=$(${lib.getExe pkgs.efibootmgr} | grep -i windows | grep -oP 'Boot\K[0-9A-F]+' | head -1)
              if [ -n "$ENTRY" ]; then
                sudo efibootmgr --bootnext "$ENTRY" && systemctl --no-wall reboot
              fi
            '';
          };
        in
        {
          action = "command";
          command = lib.getExe switch-to-windows;
          enabled = true;
          glyph = "brand-windows-filled";
          label = "Reboot to Windows";
          variant = "default";
        }
      )
      {
        action = "command";
        command = "systemctl --no-wall reboot --firmware-setup";
        enabled = true;
        glyph = "settings";
        label = "Reboot to UEFI";
        variant = "default";
      }
    ];

    boot.loader.limine.extraConfig = ''
      remember_last_entry: no
    '';

    # do not change
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
