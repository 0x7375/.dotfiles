{
  config,
  lib,
  ...
}:

let
  inherit (config.me) sshKeys;
in
{
  imports = [
    ./hardware.nix
    ./options.nix
  ]
  ++ (lib.my.filesIn ./modules);

  users.users.${config.me.user}.openssh.authorizedKeys.keys = [
    sshKeys.ryusei
  ];

  powerManagement.cpuFreqGovernor = "performance";

  boot.supportedFilesystems = [ "ntfs" ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  unfree-packages = [
    "nvidia-x11"
    "nvidia-settings"
  ];

  # wayland.windowManager.hyprland.settings.input = {
  #   accel_profile = "flat";
  # };

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
