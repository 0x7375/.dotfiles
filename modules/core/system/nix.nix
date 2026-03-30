{
  flake.shared.core =
    {
      pkgs,
      config,
      inputs,
      lib,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfree-packages;

      nixpkgs.overlays = [
        (final: prev: {
          # adapted from: https://github.com/NixOS/nix/pull/15297
          lix = prev.lix.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./nix_shell_packages_env_var.patch ];
          });

          unstable = import inputs.nixpkgs-unstable {
            inherit (final.stdenv.hostPlatform) system;
            config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
          };
          auto = import inputs.auto-update {
            inherit (final.stdenv.hostPlatform) system;
            config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
          };

          my = prev.my or { } // inputs.self.packages.${final.stdenv.hostPlatform.system};
        })
      ]
      ++ [ inputs.nur.overlays.default ];

      nixpkgs.flake = {
        setFlakeRegistry = false;
        setNixPath = false;
      };

      nix = {
        package = pkgs.lix;
        extraOptions = ''
          warn-dirty = false
          trusted-users = root ${config.me.user}

          connect-timeout = 10
          # still build when a cache fails
          fallback = true
        '';
        nixPath = pkgs.lib.mapAttrsToList (key: value: "${key}=${value}") inputs;
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
        };
        registry =
          pkgs.lib.mapAttrs (_: flake: { inherit flake; }) (pkgs.lib.filterAttrs (_: v: v ? outputs) inputs)
          // {
            unstable.flake = inputs.nixpkgs-unstable;
            auto.flake = inputs.auto-update;
            n.flake = inputs.nixpkgs;
            t = {
              from.type = "indirect";
              from.id = "tmpl";
              to.type = "git";
              to.url = "https://codeberg.org/0x7E/templates";
            };
          };
      };

      activation = # bash
        ''
          [[ -e /root/.nix-defexpr/channels ]] && rm -f /root/.nix-defexpr/channels
          [[ -e /nix/var/nix/profiles/per-user/root/channels ]] && rm -f /nix/var/nix/profiles/per-user/root/channels
        '';
    };

  flake.nixos.core =
    { config, ... }:
    {
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
