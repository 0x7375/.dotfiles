{
  imports = [
    ./hardware.nix
    ./options.nix
    ./kanshi.nix
  ];

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

  tinted.files.".config/hypr/hyprland.conf".text =
    # hyprlang
    ''
      input {
        accel_profile = flat
      }
    '';

  time.hardwareClockInLocalTime = true;

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
