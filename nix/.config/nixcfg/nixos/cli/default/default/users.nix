{
  lib,
  config,
  pkgs,
  ...
}:

{
  users.users.${config.me.user} = {
    isNormalUser = true;
    home = "/home/${config.me.user}";
    initialPassword = "pw123";
    initialHashedPassword = lib.mkForce null;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      config.me.gitPublicKey
    ];
  };

  users.users.root = {
    initialPassword = "root";
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWI0J9d+d35sPWOwXOG2nYq1jMicJlI7buXPd1lMR/a"
    ];
  };
}
