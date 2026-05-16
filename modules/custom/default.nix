{ self, ... }:

{
  flake.modules.nixos.custom.imports = [ self.modules.generic.custom ];
  flake.modules.darwin.custom.imports = [ self.modules.generic.custom ];
}
