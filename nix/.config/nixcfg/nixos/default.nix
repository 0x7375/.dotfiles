{ config, myLib, ... }:

{
  imports = [
    ../lib
  ] ++ myLib.filesIn ../modules/nixos;

  # these directories are owned by root on install for some reasons
  systemd.tmpfiles.rules = [
    "d /home/${config.me.user}/.local 0755 ${config.me.user} users - -"
    "d /home/${config.me.user}/.local/share 0755 ${config.me.user} users - -"
  ];
}
