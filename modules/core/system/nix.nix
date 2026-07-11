{ self, ... }:

{
  flake.modules.generic.core =
    {
      config,
      inputs,
      lib,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfree-packages;

      nixpkgs.overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (final.stdenv.hostPlatform) system;
            config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
          };
          auto = import inputs.auto-update {
            inherit (final.stdenv.hostPlatform) system;
            config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
          };

          my = prev.my or { } // self.packages.${final.stdenv.hostPlatform.system};
        })
      ]
      ++ [ inputs.nur.overlays.default ];

      nixpkgs.flake = {
        setFlakeRegistry = false;
        setNixPath = false;
      };

      nix =
        let
          flakes = lib.filterAttrs (_: input: lib.isType "flake" input) inputs;
          nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakes;
        in
        {
          extraOptions = ''
            warn-dirty = false
            trusted-users = root ${config.me.user}

            connect-timeout = 10
            stalled-download-timeout = 10
            # still build when a cache fails
            fallback = true
          '';

          inherit nixPath;
          channel.enable = false;
          settings = {
            flake-registry = "";
            experimental-features = [ "nix-command flakes" ];
            use-xdg-base-directories = true;
            substituters = [ "https://nix-community.cachix.org" ];
            trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
            auto-optimise-store = true;
            keep-going = true;
            log-lines = 20;
            nix-path = nixPath;
          };
          registry = {
            unstable.flake = inputs.nixpkgs-unstable;
            auto.flake = inputs.auto-update;
            n.flake = inputs.nixpkgs;
            nixpkgs.flake = inputs.nixpkgs;
            t = {
              from.type = "indirect";
              from.id = "tmpl";
              to.type = "git";
              to.url = "https://codeberg.org/0x7E/templates";
            };
          };
        };
    };

  flake.modules.nixos.core =
    { config, pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          # adapted from: https://github.com/NixOS/nix/pull/15297
          lix = final.unstable.lix.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./nix_shell_packages_env_var.patch ];
            doCheck = false;
            doInstallCheck = false;
          });
        })
      ];

      nix.package = pkgs.lix;

      persistUser.directories = [
        ".config/nixcfg"
        ".cache/nix"
        ".local/share/nix"
        ".local/state/nd"
        ".local/state/nix"
      ];

      programs.nh = {
        enable = true;
        flake = config.me.flakeDir;
        clean = {
          enable = false;
          dates = "daily";
          extraArgs = "--keep 5";
        };
      };
    };
}
