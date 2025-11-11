{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable {
  packages = with pkgs; [
    protonvpn-gui
    stable.ente-auth
  ];

  programs.seahorse.enable = true;
}
