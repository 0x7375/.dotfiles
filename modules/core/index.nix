{ inputs, ... }:

{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  services.locate.enable = true;

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enable = true;
}
