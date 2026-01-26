{
  lib,
  config,
  pkgs,
  ...
}:

{
  users.users.${config.me.user} = {
    isNormalUser = true;
    home = config.me.home;
    initialPassword = "pw123";
    initialHashedPassword = lib.mkForce null;
    uid = config.me.uid;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "input"
    ];
  };

  users.users.root = {
    initialPassword = "root";
    initialHashedPassword = lib.mkForce null;
  };

  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = { };
}
