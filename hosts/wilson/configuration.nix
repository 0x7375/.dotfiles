{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.me) host;

in
{
  imports = [
    ./hardware.nix
    ./options.nix
  ]
  ++ (lib.my.filesIn ./modules);

  documentation.man.generateCaches = lib.mkForce false;

  users.users.${config.me.user} = {
    extraGroups = [ "video" ];

    openssh.authorizedKeys.keys =
      with config.me.hosts;
      map (h: h.sshPublicKey) [
        cray
        naitoh
        mach
        julliard
      ];
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

  systemd.services."service-failure-notify@" = {
    description = "Send notification when a service fails";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.curl} -d \"Service %i failed\" http://${host.ips.lan}:8719/status";
    };
  };

  programs.nh.clean.extraArgs = lib.mkForce "--keep 2 --keep-since 7d";

  system.stateVersion = "24.11";
}
