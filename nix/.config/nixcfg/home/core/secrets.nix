{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = lib.mkIf config.me.secrets.enable {
    sops.age.sshKeyPaths = [ "/home/${config.me.user}/.ssh/id_ed25519" ];

    home.activation.generateSopsKey =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          [[ ! -e /home/${config.me.user}/.config/sops/age/keys.txt ]] && {
            run mkdir -p /home/${config.me.user}/.config/sops/age
            run ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ${builtins.head config.sops.age.sshKeyPaths} \
              -o /home/${config.me.user}/.config/sops/age/keys.txt
          }
        '';
  };
}
