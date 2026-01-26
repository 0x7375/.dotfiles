{
  lib,
  options,
  ...
}:

lib.mkMerge [
  (lib.optionalAttrs (options ? services.locate) {
    services.locate.enable = true;
  })
  {
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enable = true;
  }
]
