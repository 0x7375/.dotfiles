{ self, ... }:

{
  flake.nixos.custom.imports = [ self.shared.custom ];
  flake.darwin.custom.imports = [ self.shared.custom ];
}
