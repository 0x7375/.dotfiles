{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "dump-dotfiles";
  runtimeInputs = with pkgs; [
    coreutils
    findutils
    gnused
  ];
  text = ''
    set -euo pipefail

    export_dir="$(mktemp -d)"

    [[ ! -d ''${export_dir} ]] && echo "Export directory not found" && exit 1

    chmod -R u+rw "''${export_dir}"
    chmod -R u+rw "''${export_dir}"

    sed -i '/LOCALE_ARCHIVE/d' "''${export_dir}"/.profile

    ignore=(
        ".config/direnv"
        ".config/environment.d"
    )

    for i in "''${ignore[@]}"; do
        rm -rf "''${export_dir:?}"/"''${i}"
    done

    find "''${export_dir}" -type f -exec sed -i 's|/nix/store/[a-z0-9]*-[^/]*/bin/||g' {} +

    sed -i '/icon_path=/d' "''${export_dir}"/.config/dunst/dunstrc

    sed -i '/@import/d' "''${export_dir}"/.config/gtk-4.0/gtk.css
    echo "Dotfiles exported to ''${export_dir}"
  '';
}
