{
  config,
  myLib,
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

  users.users.${config.me.user}.openssh.authorizedKeys.keys = [
    myLib.ssh-keys.ryusei
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    myLib.ssh-keys.ryusei
  ];

  boot.supportedFilesystems = [ "ntfs" ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.hardware.openrgb.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
