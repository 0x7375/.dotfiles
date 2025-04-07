{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:

{
  imports = [
    ../lib
  ] ++ (myLib.filesIn ../modules/home);

  xdg.configFile."nixpkgs/config.nix".text = # nix
    ''
      {
        allowUnfree = true;
      }
    '';

  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.use-xdg-base-directories = true;

  home.username = config.me.user;
  home.homeDirectory = "/home/${config.me.user}";

  home.stateVersion = "23.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
