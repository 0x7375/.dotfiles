{
  self,
  inputs,
  ...
}:

let
  lib = inputs.nixpkgs.lib;
  mkHost =
    type: name: extraModules:
    let
      isNixos = type == "nixos";
      mkSystem = if isNixos then lib.nixosSystem else inputs.nix-darwin.lib.darwinSystem;
      mod = if isNixos then "nixosModules" else "darwinModules";
      modName = if isNixos then "nixos" else "darwin";
    in
    mkSystem {
      inherit lib;
      specialArgs = {
        inherit inputs;
        inherit (inputs) secrets;
      };
      modules = [
        inputs.sops-nix.${mod}.sops
        inputs.nix-index-database.${mod}.nix-index
        inputs.hjem.${mod}.default

        self.${modName}.${name}
        self.${modName}.core
        self.shared.custom
        { networking.hostName = name; }
      ]
      ++ lib.optionals isNixos [
        inputs.disko.nixosModules.disko
        self.nixos.custom
        self.nixos.overrides
      ]
      ++ extraModules;
    };
in
{
  # allow these options to be merged
  options.flake =
    let
      attrsOption = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.deferredModule;
        default = { };
      };
    in
    {
      nixos = attrsOption;
      darwin = attrsOption;
      shared = attrsOption;
    };

  config = {
    flake.nixosConfigurations = {
      cray = mkHost "nixos" "cray" (
        (with self.nixos; [
          boot
          secrets
          networkEnvironment
          keyd
          btrfs
          syncthingClient
        ])
        ++ (with self.shared; [
          dev
        ])
      );
      naitoh = mkHost "nixos" "naitoh" (
        (with self.nixos; [
          boot
          secrets
          networkEnvironment
          keyd
          btrfs
          syncthingClient
          vpnPeer
        ])
        ++ (with self.shared; [
          dev
        ])
      );
    };

    flake.darwinConfigurations = {
      mach =
        mkHost "darwin" "mach" [
          inputs.nix-homebrew.darwinModules.nix-homebrew
        ]
        ++ (with self.darwin; [
          vpnPeer
          network
          secrets
          vpnPeer
        ]);
    };
  };
}
