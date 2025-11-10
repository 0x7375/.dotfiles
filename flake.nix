{
  description = "NixOS";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.follows = "nixpkgs-unstable";
    # nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrappers = {
      url = "github:Lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-update.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
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

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos-wsl = {
    #   url = "github:nix-community/NixOS-WSL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { ... }@inputs:
    let
      lib = inputs.nixpkgs.lib.extend (
        self: super: {
          my = import ./lib { lib = self; };
        }
      );

      aarch = "aarch64-linux";
      x86 = "x86_64-linux";

      mkSystem =
        hostname: system:
        inputs.nixpkgs.lib.nixosSystem {
          # nixpkgsPatcher = {
          #   inherit inputs;
          #   nixpkgs = inputs.nixpkgs-unstable;
          # };
          inherit lib;
          specialArgs = {
            inherit (inputs) secrets;
            inherit inputs;
          };
          modules = [
            ./hosts/${hostname}/configuration.nix
            {
              imports = lib.my.filesIn ./modules;
              networking.hostName = hostname;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        yugen = mkSystem "yugen" x86;
        ryusei = mkSystem "ryusei" x86;
        tenkuu = mkSystem "tenkuu" x86;
        hikari = mkSystem "hikari" aarch;
        # kumo = mkSystem "kumo" x86;
        isoImg = mkSystem "isoImg" x86;
      };
    };
}
