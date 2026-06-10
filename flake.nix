{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    auto-update.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "auto-update";
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # nixos-wsl = {
    #   url = "github:nix-community/NixOS-WSL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    asahi-firmware = {
      url = "git+ssh://git@codeberg.org/0x7E/asahi-firmware";
      flake = false;
    };

    hjem = {
      url = "github:feel-co/hjem";
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
    token2 = {
      url = "git+ssh://git@codeberg.org/0x7E/token2-totp-cli";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "auto-update";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nd = {
      url = "git+https://codeberg.org/0x7E/nd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    karabiner-ts = {
      url = "git+https://codeberg.org/0x7E/karabiner-ts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      import-tree =
        path:
        let
          inherit (inputs.nixpkgs.lib) fileset hasInfix;
          nixFiles = fileset.toList (fileset.fileFilter (f: f.hasExt "nix") path);
        in
        builtins.filter (p: !(hasInfix "/_" (toString p))) nixFiles;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.wrappers.flakeModules.wrappers
        inputs.git-hooks-nix.flakeModule
      ]
      ++ (import-tree ./modules);

      flake.lib.import-tree = import-tree;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          wrappers.control_type = "exclude";
          wrappers.packages = { };

          pre-commit.settings.hooks = {
            stylua.enable = true;
            nixfmt.enable = true;
            statix = {
              enable = true;
              entry = "${lib.getExe pkgs.statix} fix";
            };
            deadnix = {
              enable = true;
              settings = {
                edit = true;
                noUnderscore = true;
                noLambdaArg = true;
                noLambdaPatternNames = true;
              };
            };
          };

          devShells.default = pkgs.mkShell {
            shellHook = config.pre-commit.installationScript;
          };
        };
    };
}
