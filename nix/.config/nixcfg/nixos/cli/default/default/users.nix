{
  lib,
  myLib,
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
  };

  users.users.root = {
    initialPassword = "root";
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      myLib.ssh-keys.yugen
    ];
  };
}
