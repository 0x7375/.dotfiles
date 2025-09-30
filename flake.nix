{
  description = "NixOS and home-manager configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs.follows = "nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-maid.url = "github:viperML/nix-maid";
    # wrapper.url = "github:viperLM/wrapper-manager";

    auto-update.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    unf = {
      url = "git+https://git.atagen.co/atagen/unf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { ... }@inputs:
    let
      myLib = import ./lib/myLib.nix { inherit inputs; };
      aarch = "aarch64-linux";
      x86 = "x86_64-linux";
      inherit (myLib) mkSystem;
    in
    {
      nixosConfigurations = {
        yugen = mkSystem "yugen" x86;
        ryusei = mkSystem "ryusei" x86;
        hikari = mkSystem "hikari" aarch;
        kumo = mkSystem "kumo" x86;
        isoImg = mkSystem "isoImg" x86;
      };
    };
}
