{
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./options.nix
  ]
  ++ (lib.my.filesIn ./modules);

  services.picom.enable = lib.mkForce false;

  powerManagement.cpuFreqGovernor = "performance";

  boot.supportedFilesystems = [ "ntfs" ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.loader.systemd-boot.extraInstallCommands = ''
    sed -i 's/^default .*/default auto-windows/' /boot/loader/loader.conf
  '';

  vars.LIBVA_DRIVER_NAME = "nvidia";

  services.xserver.videoDrivers = [ "nvidia" ];
  unfree-packages = [
    "nvidia-x11"
    "nvidia-settings"
  ];

  nix.settings = {
    cores = 5;
    max-jobs = 4;
  };

  # wayland.windowManager.hyprland.settings.input = {
  #   accel_profile = "flat";
  # };

  time.hardwareClockInLocalTime = true;

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
