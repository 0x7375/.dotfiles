{
  inputs,
  secrets,
  config,
  lib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets.laptop_vpn_psk = {
    owner = config.me.user;
  };

  sops.defaultSopsFile = "${secrets}/default.yaml";
  sops.age.sshKeyPaths = [ "/home/${config.me.user}/.ssh/id_ed25519" ];
}
