{ lib, myLib, ... }:

{
  imports = [
    ./options.nix
  ]
  ++ (myLib.filesIn ../../home);

  programs.man.generateCaches = lib.mkForce false;
}
