{
  description = "NixOS";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.follows = "nixpkgs-unstable";
    # nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    auto-update.url = "github:nixos/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # nixos-wsl = {
    #   url = "github:nix-community/NixOS-WSL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:Lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@codeberg.org/0x7E/nix-secrets";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "auto-update";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nd.url = "git+https://codeberg.org/0x7E/nd";
    karabiner-ts.url = "git+https://codeberg.org/0x7E/karabiner-ts";
  };
  outputs =
    { ... }@inputs:
    let
      lib = inputs.nixpkgs.lib.extend (
        self: super: {
          my = import ./lib { lib = self; };
        }
      );

      mkHost =
        type: name:
        let
          isNixos = type == "nixos";
          builder = if isNixos then lib.nixosSystem else inputs.nix-darwin.lib.darwinSystem;
          modules = if isNixos then "nixosModules" else "darwinModules";
        in
        builder {
          inherit lib;
          specialArgs = {
            inherit (inputs) secrets;
            inherit inputs;
            mkNixos = if isNixos then (a: a) else (a: { });
            mkDarwin = if !isNixos then (a: a) else (a: { });
            mkBundle =
              attrs:
              lib.mkMerge [
                (removeAttrs attrs [
                  "nixos"
                  "darwin"
                ])
                (attrs.${if isNixos then "nixos" else "darwin"} or { })
              ];
          };
          modules = [
            ./hosts/${name}/configuration.nix
            inputs.sops-nix.${modules}.sops
            inputs.nix-index-database.${modules}.nix-index
            inputs.hjem.${modules}.default
            {
              imports = lib.my.filesIn ./modules;
              networking.hostName = name;
            }
          ]
          ++ lib.optionals isNixos [ inputs.disko.nixosModules.disko ]
          ++ lib.optionals (!isNixos) [ inputs.nix-homebrew.darwinModules.nix-homebrew ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs [
        "cray"
        "naitoh"
        "wilson"
        "isoImg"
        # "julliard"
        # "perlman"
      ] (mkHost "nixos");
      darwinConfigurations = lib.genAttrs [ "mach" ] (mkHost "darwin");
    };
}
