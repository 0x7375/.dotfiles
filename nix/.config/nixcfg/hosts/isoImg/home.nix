{ osConfig, ... }:

{
  imports = [
    ./options.nix
    ../../home
  ];

  nixpkgs.overlays = osConfig.nixpkgs.overlays;
}
