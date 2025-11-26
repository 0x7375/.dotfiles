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
  ];

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys =
      with config.me.hosts;
      map (h: h.sshPublicKey) [
        cray
        naitoh
        julliard
      ];
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  packages = [
    pkgs.ncdu
    pkgs.xsel
  ];

  services.journald.extraConfig = ''
    SystemMaxFileSize=40M
    SystemMaxUse=200M
  '';

  programs.nh.clean.extraArgs = lib.mkForce "--keep 2 --keep-since 7d";

  system.stateVersion = "24.11";
}
