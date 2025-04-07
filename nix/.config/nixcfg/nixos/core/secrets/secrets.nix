{
  inputs,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = lib.mkIf config.me.secrets.enable {
    environment.systemPackages = [ pkgs.sops ];

    sops.secrets.server_vpn_endpoint = {
      owner = config.me.user;
    };

    sops.secrets.laptop_vpn_psk = {
      owner = config.me.user;
    };

    sops.defaultSopsFile = "${secrets}/default.yaml";
    sops.age.sshKeyPaths = [ "/home/${config.me.user}/.ssh/id_ed25519" ];

    sops.secrets.cachix = { };
  };
}
