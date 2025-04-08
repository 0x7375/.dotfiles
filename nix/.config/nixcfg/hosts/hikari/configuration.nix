{
  pkgs,
  config,
  myLib,
  lib,
  ...
}:

{
  imports =
    [
      ./hardware.nix
      ./options.nix
    ]
    ++ (myLib.filesIn ./nixos)
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

  services.journald.extraConfig = ''
    MaxRetentionSec=2week
  '';

  systemd.services."service-failure-notify@" = {
    description = "Send notification when a service fails";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -d \"Service %i failed\" http://${myLib.network.lan.addr.server}:8719/status";
    };
  };

  programs.nh.clean.extraArgs = lib.mkForce "--keep 2 --keep-since 7d";

  system.stateVersion = "24.11";
}
