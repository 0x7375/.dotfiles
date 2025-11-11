{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "nlink";
  text = ''
    # https://github.com/iynaix/dotfiles/blob/bd2f8aaea20abf76dc1dcd54071b8037e3bfa088/modules/shell/nix/packages.nix
    if [ "$#" -eq 0 ]; then
        echo "No file(s) specified."
        exit 1
    fi

    for file in "$@"; do
      if [[ "$file" == *.bak ]]; then
          continue
      fi

      if [ -L "$file" ]; then
          mv "$file" "$file.bak"
          cp -L "$file.bak" "$file"
          chmod +w "$file"

      elif [ -f "$file" ] && [ -L "$file.bak" ]; then
          mv "$file.bak" "$file"
      fi
    done
  '';
}
