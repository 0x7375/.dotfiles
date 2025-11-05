{
  lib,
  inputs,
  myLib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    inputs.hjem.nixosModules.default
    (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" config.me.user ])
  ];

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
      "input"
    ];
  };

  hjem = {
    # linker = inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.smfh;
    users.${config.me.user}.enable = true;
    clobberByDefault = true;
  };

  users.users.root = {
    initialPassword = "root";
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      myLib.ssh-keys.yugen
      myLib.ssh-keys.ryusei
    ];
  };

  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = { };
}
