{ myLib, osConfig, ... }:

{
  imports = [
    ./options.nix
  ] ++ (myLib.filesIn ../../home);

  nixpkgs.overlays = osConfig.nixpkgs.overlays;
}
