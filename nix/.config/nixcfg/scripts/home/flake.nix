{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "flake";
  runtimeInputs = with pkgs; [
    curl
  ];
  text = ''
    OWNER="0xB0F"
    REPO="templates"
    REPO_URL="https://codeberg.org/''${OWNER}/''${REPO}"

    if [ $# -eq 0 ]; then
      echo "Usage: flake <flake-subdirectory>"
      echo "Available templates:"
      API_URL="https://codeberg.org/api/v1/repos/''${OWNER}/''${REPO}/contents"

      DIRS=$(curl -fsSL "$API_URL" | jq -r '.[] | select(.type == "dir") | .name')

      if [ -z "$DIRS" ]; then
        echo "Error: No templates found"
        exit 1
      fi

      echo "$DIRS" | while read -r dir; do
        echo "  • $dir"
      done
      exit 1
    fi

    flake_url="''${REPO_URL}/raw/branch/main/$1/flake.nix"

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
