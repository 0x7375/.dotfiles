{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./options.nix
  ]
  ++ (lib.my.filesIn ./modules);

  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      crossPkgs = import prev.path {
        localSystem = "x86_64-linux";
        crossSystem = "aarch64-linux";
        config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
      };
    })
  ];

  documentation.man.generateCaches = lib.mkForce false;

  users.users.root.openssh.authorizedKeys.keys = config.me.hosts.yubikey.sshPublicKeys;

  users.users.${config.me.user} = {
    extraGroups = [ "video" ];

    openssh.authorizedKeys.keys = config.me.hosts.mach.sshPublicKeys;
  };

  security.pam.services = {
    login.unixAuth = lib.mkForce true;
    sudo.unixAuth = lib.mkForce true;
  };

  packages = with pkgs; [
    ncdu
    xclip
    my.pw-backup
  ];

  services.journald.extraConfig = ''
    SystemMaxFileSize=40M
    SystemMaxUse=200M
  '';

  programs.nh.clean.extraArgs = lib.mkForce "--keep 2 --keep-since 7d";

  system.stateVersion = "24.11";
}
