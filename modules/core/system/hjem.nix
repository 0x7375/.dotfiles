{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" config.me.user ])
  ];

  hjem = {
    linker = inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.smfh;
    users.${config.me.user}.enable = true;
    clobberByDefault = true;
  };
}
