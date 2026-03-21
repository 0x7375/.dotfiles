{
  pkgs,
  lib,
  mkBundle,
  config,
  inputs,
  ...
}:

mkBundle {
  nixpkgs.overlays = [
    (final: prev: {
      nix = final.unstable.nix.override {
        nix-cli = final.unstable.nix.nix-cli.overrideAttrs (old: {
          # https://github.com/NixOS/nix/pull/15297
          patches = (old.patches or [ ]) ++ [ ./nix_shell_packages_env_var.patch ];
        });
      };
    })
  ];

  nixpkgs.flake = {
    setFlakeRegistry = false;
    setNixPath = false;
  };

  nix = {
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
      experimental-features = [ "nix-command flakes pipe-operators" ];
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

  nixos.programs.nh = {
    enable = true;
    flake = config.me.flakeDir;
    clean = {
      enable = false;
      dates = "daily";
      extraArgs = "--keep 5";
    };
  };
}
