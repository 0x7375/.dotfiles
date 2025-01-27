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

  environment.shellInit = # bash
    ''
      switch-vpn () {
        [[ $1 == "home" ]] && sudo systemctl stop wg-quick-protonvpn && sudo systemctl start wg-quick-homevpn 
        [[ $1 == "proton" ]] && sudo systemctl stop wg-quick-homevpn && sudo systemctl start wg-quick-protonvpn
      }
    '';

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  system.stateVersion = "24.11";
}
