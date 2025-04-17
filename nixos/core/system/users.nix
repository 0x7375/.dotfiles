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
    uid = config.me.uid;
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

  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = { };
}
