{
  lib,
  config,
  inputs,
  ...
}:

{
  nix = {
    extraOptions = ''
      warn-dirty = false
      trusted-users = root ${config.me.user}
    '';
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = false;
    settings = {
      experimental-features = [ "nix-command flakes pipe-operators" ];
      use-xdg-base-directories = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://ayko.cachix.org"
        # "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ayko.cachix.org-1:pglseKMD4PGHDRvF4LzDJKXOo0gSj3yWZU6QXI6YkBs="
        # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      auto-optimise-store = true;
    };
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      stable.flake = inputs.nixpkgs-stable;
      n.flake = inputs.nixpkgs;
      nur.flake = inputs.nur;
    };
  };

  system.activationScripts.cleanup-channels.text = # bash
    ''
      [[ -e /root/.nix-defexpr/channels ]] && rm -f /root/.nix-defexpr/channels
      [[ -e /nix/var/nix/profiles/per-user/root/channels ]] && rm -f /nix/var/nix/profiles/per-user/root/channels
    '';
}
