{
  pkgs,
  config,
  myLib,
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./options.nix
  ]
  ++ (myLib.filesIn ../../nixos);

  networking.hostName = config.me.hostname;

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys =
      let
        inherit (myLib) ssh-keys;
      in
      [
        ssh-keys.yugen
        ssh-keys.ryusei
        ssh-keys.kumo
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
