{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "flake";
  runtimeInputs = with pkgs; [
    curl
  ];
  text = ''
    REPO="https://git.sr.ht/~ayko/templates"

    if [ -z "$1" ]; then
      echo "Usage: $0 <flake-subdirectory>"
      exit 1
    fi

    flake_url="''${REPO}/blob/main/$1/flake.nix"

    [ ! -f .envrc ] && {
      echo "use_flake" > .envrc
      echo ".envrc created with 'use_flake'"
    }

    if [ -f flake.nix ]; then
      echo "flake.nix already exists"
      exit 1
    fi

    if ! curl -fsSL "$flake_url" -o flake.nix; then
      echo "Error: Remote flake not found or failed to fetch at ''${flake_url}"
      exit 1
    else
      echo "flake.nix created with flake from ''${flake_url}"
    fi
  '';
}
