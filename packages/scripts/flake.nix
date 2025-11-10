{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "flake";
  runtimeInputs = with pkgs; [
    curl
  ];
  text = ''
    owner="0x7E"
    repo="templates"
    repo_url="https://codeberg.org/''${owner}/''${repo}"

    if [[ $# -eq 0 ]]; then
      echo "Usage: flake <flake-subdirectory>"
      echo "Available templates:"
      api_url="https://codeberg.org/api/v1/repos/''${owner}/''${repo}/contents"

      dirs=$(curl -fsSL "$api_url" | jq -r '.[] | select(.type == "dir") | .name')

      if [[ -z $dirs ]]; then
        echo "Error: No templates found"
        exit 1
      fi

      echo "$dirs" | while read -r dir; do
        echo "  • $dir"
      done
      exit 1
    fi

    flake_url="''${repo_url}/raw/branch/main/$1/flake.nix"

    [[ ! -f .envrc ]] && {
      echo "use_flake" > .envrc
      echo ".envrc created with 'use_flake'"
    }

    if [[ -f flake.nix ]]; then
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
