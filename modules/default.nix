{
  self,
  inputs,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;
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

        self.modules.${modName}.${name}
        self.modules.${modName}.core
        self.modules.${modName}.custom
        { networking.hostName = name; }
      ]
      ++ lib.optionals isNixos [
        inputs.disko.nixosModules.disko
        self.modules.nixos.overrides
      ]
      ++ extraModules;
    };
in
{
  # allow it to be merged
  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };

  config = {
    flake.nixosConfigurations = {
      cray = mkHost "nixos" "cray" (
        with self.modules.nixos;
        [
          boot
          secrets
          networkEnvironment
          keyd
          btrfs
          vpnPeer
          syncthingClient
          desktop
          wayland
          dev
        ]
      );

      naitoh = mkHost "nixos" "naitoh" (
        with self.modules.nixos;
        [
          boot
          secrets
          networkEnvironment
          keyd
          btrfs
          syncthingClient
          vpnPeer
          desktop
          wayland
          dev
        ]
      );

      pearlman = mkHost "nixos" "pearlman" (
        with self.modules.nixos;
        [
          boot
          secrets
          syncthing
          network
        ]
      );

      isoImg = mkHost "nixos" "isoImg" [ self.modules.nixos.keyd ];
    };

    flake.darwinConfigurations = {
      mach = mkHost "darwin" "mach" (
        [
          inputs.nix-homebrew.darwinModules.nix-homebrew
        ]
        ++ (with self.modules.darwin; [
          secrets
          vpnPeer
          desktop
          alacritty
          network
          dev
        ])
      );
    };
  };
}
