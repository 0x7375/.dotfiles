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
    # inputs.sops-nix.nixosModules.sops
    inputs.sops-nix.darwinModules.sops
  ];

  config = lib.mkIf config.me.secrets.enable {
    packages = [ pkgs.sops ];

    sops.secrets.server_vpn_endpoint.owner = config.me.user;

    sops.defaultSopsFile = "${secrets}/default.yaml";
    sops.age.sshKeyPaths = [ "${config.me.home}/.ssh/id_ed25519" ];
    sops.gnupg.sshKeyPaths = [ ];

    system.activationScripts.generateSopsKey.text = # bash
      ''
        [[ ! -e ${config.me.home}/.config/sops/age/keys.txt ]] && {
          mkdir -p ${config.me.home}/.config/sops/age
          ${lib.getExe pkgs.ssh-to-age} -private-key -i ${builtins.head config.sops.age.sshKeyPaths} \
            -o ${config.me.home}/.config/sops/age/keys.txt
        }
      '';
  };
}
