{
  mkNixos,
  lib,
  config,
  ...
}:

lib.mkIf config.me.secrets.enable (mkNixos {
  users.mutableUsers = false;

  sops.secrets.user_pw.neededForUsers = true;
  sops.secrets.root_pw.neededForUsers = true;

  users.users.${config.me.user} = {
    initialPassword = lib.mkForce null;
    hashedPasswordFile = config.sops.secrets.user_pw.path;
  };

  users.users.root = {
    initialPassword = lib.mkForce null;
    hashedPasswordFile = config.sops.secrets.root_pw.path;
  };
})

