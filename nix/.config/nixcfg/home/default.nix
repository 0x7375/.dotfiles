{
  system,
  inputs,
  config,
  myLib,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../lib
    ./cli
    ./gui
  ] ++ myLib.filesIn ./modules;

  systemd.user.tmpfiles.rules =
    let
      inherit (config.me) user;
    in
    [
      "d /home/${user}/.local/share 0700 ${user} users -"
      "d /home/${user}/.local/share/steam 0770 ${user} users -"
      "d /home/${user}/.local/state 0700 ${user} users -"
    ];

  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.use-xdg-base-directories = true;

  home.username = config.me.user;
  home.homeDirectory = "/home/${config.me.user}";

  home.stateVersion = "23.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
