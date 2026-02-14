{
  pkgs,
  secrets,
  config,
  lib,
  mkBundle,
  ...
}:

lib.mkIf config.me.secrets.enable (mkBundle {
  packages = [ pkgs.sops ];

  sops.defaultSopsFile = "${secrets}/default.yaml";
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.sshKeyPaths = [ ];

  nixos = {
    sops.age.sshKeyPaths = [ "${config.me.home}/.ssh/id_ed25519" ];

    activation = # bash
      ''
        [[ ! -e ${config.me.home}/.config/sops/age/keys.txt ]] && {
          mkdir -p ${config.me.home}/.config/sops/age
          ${lib.getExe pkgs.ssh-to-age} -private-key -i ${builtins.head config.sops.age.sshKeyPaths} \
            -o ${config.me.home}/.config/sops/age/keys.txt
        }
      '';
  };

  darwin.sops.age = {
    keyFile = "/var/lib/sops-nix/se-identity.txt";
    plugins = [ pkgs.age-plugin-se ];
  };
})
