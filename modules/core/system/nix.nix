{
  pkgs,
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

  nix = {
    extraOptions = ''
      warn-dirty = false
      trusted-users = root ${config.me.user}

      connect-timeout = 10
      # still build when a cache fails
      fallback = true
    '';
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
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
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      unstable.flake = inputs.nixpkgs-unstable;
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
    enable = false;
    flake = config.me.flakeDir;
    clean = {
      enable = false;
      dates = "daily";
      extraArgs = "--keep 5";
    };
  };
}
