{
  mkBundle,
  ...
}:

mkBundle {
  nixos.services.locate.enable = true;

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enable = true;
}

