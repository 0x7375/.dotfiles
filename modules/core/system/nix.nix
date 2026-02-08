{
  mkBundle,
  config,
  inputs,
  ...
}:

mkBundle {
  nix = {
    extraOptions = ''
      warn-dirty = false
      trusted-users = root ${config.me.user}
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
      stable.flake = inputs.nixpkgs-stable;
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
    clean.enable = true;
    clean.extraArgs = "--keep 5 --keep-since 7d";
    flake = config.me.flakeDir;
  };
}
