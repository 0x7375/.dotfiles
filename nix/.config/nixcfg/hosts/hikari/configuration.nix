{
  pkgs,
  config,
  myLib,
  ...
}:

{
  imports = [
    ../../nixos
    ./hardware.nix
    ./options.nix
  ] ++ (myLib.filesIn ./nixos);

  networking.hostName = config.me.hostname;

  users.users.${config.me.user} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53 yugen"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9wtfhfEPZ6GVA4FWRUk5KXtTttn6Q4qjxO1apMc7RK ryusei"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcGpmfziJoYbPbfdZi/REVStrNgl+F8lwVf1t2oLdaZ kumo"
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

  system.stateVersion = "24.11";
}
