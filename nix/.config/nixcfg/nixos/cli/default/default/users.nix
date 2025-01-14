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
  };

  users.users.root = {
    initialPassword = "root";
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53 yugen"
    ];
  };
}
