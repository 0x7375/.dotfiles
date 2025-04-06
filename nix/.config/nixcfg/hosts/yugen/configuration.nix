{
  config,
  myLib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../nixos
    ./options.nix
  ];

  networking.hostName = config.me.hostname;

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys = [
      myLib.ssh-keys.ryusei
    ];
  };

  boot.supportedFilesystems = [ "ntfs" ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.hardware.openrgb.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  sops.secrets."yugen/syncthing/cert" = {
    owner = config.me.user;
  };

  sops.secrets."yugen/syncthing/key" = {
    owner = config.me.user;
  };

  services.syncthing = {
    cert = "${config.sops.secrets."yugen/syncthing/cert".path}";
    key = "${config.sops.secrets."yugen/syncthing/key".path}";
  };

  # do not change
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
