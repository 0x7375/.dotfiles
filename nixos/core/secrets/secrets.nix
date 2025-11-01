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
    packages = [ pkgs.sops ];

    sops.secrets.server_vpn_endpoint = {
      owner = config.me.user;
    };

    sops.secrets.laptop_vpn_psk = {
      owner = config.me.user;
    };

    sops.defaultSopsFile = "${secrets}/default.yaml";
    sops.age.sshKeyPaths = [ "/home/${config.me.user}/.ssh/id_ed25519" ];
    sops.gnupg.sshKeyPaths = [ ];

    sops.secrets.cachix = { };

    system.activationScripts.generateSopsKey.text = # bash
      ''
        [[ ! -e /home/${config.me.user}/.config/sops/age/keys.txt ]] && {
          mkdir -p /home/${config.me.user}/.config/sops/age
          ${lib.getExe pkgs.ssh-to-age} -private-key -i ${builtins.head config.sops.age.sshKeyPaths} \
            -o /home/${config.me.user}/.config/sops/age/keys.txt
        }
      '';
  };
}
