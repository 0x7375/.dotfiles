{
  description = "NixOS and home-manager configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    nixpkgs.follows = "nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-update.url = "github:nixos/nixpkgs/nixos-unstable";
    # zen-browser.url = "github:ch4og/zen-browser-flake";
    # xremap.url = "github:xremap/nix-flake";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    secrets = {
      url = "sourcehut:~ayko/nix-secrets";
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

  };
  outputs =
    { ... }@inputs:
    let
      myLib = import ./lib/myLib.nix { inherit inputs; };
      aarch = "aarch64-linux";
      x86 = "x86_64-linux";
      inherit (myLib) mkSystem mkHome mkSystemWithHome;
      hosts = {
        yugen = {
          nixos = ./hosts/yugen/configuration.nix;
          home = ./hosts/yugen/home.nix;
        };
        ryusei = {
          nixos = ./hosts/ryusei/configuration.nix;
          home = ./hosts/ryusei/home.nix;
        };
        hikari = {
          nixos = ./hosts/hikari/configuration.nix;
          home = ./hosts/hikari/home.nix;
        };
        kumo = {
          nixos = ./hosts/kumo/configuration.nix;
          home = ./hosts/kumo/home.nix;
        };
        isoImg = {
          nixos = ./hosts/isoImg/configuration.nix;
          home = ./hosts/isoImg/home.nix;
        };
      };
    in
    {
      nixosWithoutHomeConfigurations = {
        yugen = mkSystem hosts.yugen.nixos x86;
        ryusei = mkSystem hosts.ryusei.nixos x86;
        hikari = mkSystem hosts.hikari.nixos aarch;
        kumo = mkSystem hosts.kumo.nixos x86;
      };

      nixosConfigurations = {
        yugen = mkSystemWithHome hosts.yugen.nixos hosts.yugen.home x86;
        ryusei = mkSystemWithHome hosts.ryusei.nixos hosts.ryusei.home x86;
        hikari = mkSystemWithHome hosts.hikari.nixos hosts.hikari.home aarch;
        kumo = mkSystemWithHome hosts.kumo.nixos hosts.kumo.home x86;
        isoImg = mkSystemWithHome hosts.isoImg.nixos hosts.isoImg.home x86;
      };

      homeConfigurations =
        let
          user = "ayko";
        in
        {
          "${user}@yugen" = mkHome hosts.yugen.home x86;
          "${user}@ryusei" = mkHome hosts.ryusei.home x86;
          "${user}@kumo" = mkHome hosts.kumo.home x86;
          "${user}@hikari" = mkHome hosts.hikari.home aarch;
        };
    };
}
