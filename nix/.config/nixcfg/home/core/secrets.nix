{
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
  };
}
