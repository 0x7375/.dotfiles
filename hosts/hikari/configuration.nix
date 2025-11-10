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

  documentation.man.generateCaches = lib.mkForce false;

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys =
      let
        inherit (config.me) sshKeys;
      in
      [
        sshKeys.yugen
        sshKeys.ryusei
        sshKeys.kumo
      ];
  };

  packages = [
    pkgs.ncdu
    pkgs.xsel
  ];

  services.journald.extraConfig = ''
    SystemMaxFileSize=40M
    SystemMaxUse=200M
  '';

  systemd.services."service-failure-notify@" = {
    description = "Send notification when a service fails";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.curl} -d \"Service %i failed\" http://${config.me.networkIps.lan.addr.server}:8719/status";
    };
  };

  programs.nh.clean.extraArgs = lib.mkForce "--keep 2 --keep-since 7d";

  system.stateVersion = "24.11";
}
