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
  ]
  ++ (myLib.filesIn ../modules/home);

  nixpkgs.overlays = [
    (final: prev: {
      lf = prev.lf.overrideAttrs (old: rec {
        version = "0d5ffcdb04170457edcd26da0e972fddf4e0fb2d";
        src = pkgs.fetchFromGitHub {
          owner = "CatsDeservePets";
          repo = old.src.repo;
          rev = version;
          sha256 = "sLv2dUdRs65GYEpq3yrmktdV9QwZiCO/8dwEeq4nEhk=";
        };
        vendorHash = "sha256-ZShpWCfEVPLafrn3MvtxkRsBvwUEOiLBs1gZhKSBrsQ=";
      });
    })
  ];

  programs.man.generateCaches = true;

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
