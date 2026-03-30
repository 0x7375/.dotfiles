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

        self.${modName}.${name}
        self.${modName}.core
        self.${modName}.custom
        { networking.hostName = name; }
      ]
      ++ lib.optionals isNixos [
        inputs.disko.nixosModules.disko
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
      lib = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
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
          vpnPeer
          syncthingClient
          desktop
          wayland
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
          desktop
          wayland
        ])
        ++ (with self.shared; [
          dev
        ])
      );

      pearlman = mkHost "nixos" "pearlman" (
        with self.nixos;
        [
          boot
          secrets
          syncthing
          network
        ]
      );

      isoImg = mkHost "nixos" "isoImg" [ self.nixos.keyd ];
    };

    flake.darwinConfigurations = {
      mach = mkHost "darwin" "mach" (
        [
          inputs.nix-homebrew.darwinModules.nix-homebrew
        ]
        ++ (with self.darwin; [
          secrets
          vpnPeer
          desktop
          alacritty
          network
        ])
        ++ (with self.shared; [
          dev
        ])
      );
    };
  };
}
