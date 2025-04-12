{
  description = "NixOS and home-manager configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    nixpkgs.follows = "nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    media.url = "github:nixos/nixpkgs/nixos-unstable";
    auto-update.url = "github:nixos/nixpkgs/nixos-unstable";
    gns3.url = "github:nixos/nixpkgs/dd5621df6dcb90122b50da5ec31c411a0de3e538a";
    # zen-browser.url = "github:ch4og/zen-browser-flake";
    # xremap.url = "github:xremap/nix-flake";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@codeberg.org/0xB0F/nix-secrets";
      flake = false;
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

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
  };
  outputs =
    { ... }@inputs:
    let
      myLib = import ./lib/myLib.nix { inherit inputs; };
      aarch = "aarch64-linux";
      x86 = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${x86};
      inherit (myLib) mkSystem mkHome;
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
      nixosConfigurations = {
        yugen = mkSystem hosts.yugen.nixos hosts.yugen.home x86;
        ryusei = mkSystem hosts.ryusei.nixos hosts.ryusei.home x86;
        hikari = mkSystem hosts.hikari.nixos hosts.hikari.home aarch;
        kumo = mkSystem hosts.kumo.nixos hosts.kumo.home x86;
        isoImg = mkSystem hosts.isoImg.nixos hosts.isoImg.home x86;
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

      devShells.${x86}.default = pkgs.mkShell {
        shellHook = ''
          export GIT_DIR=.nix-git
        '';
      };
    };
}
