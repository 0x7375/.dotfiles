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

    declare -r EXPORT_DIR=''${HOME}/repos/dotfiles
    declare -r HM_DIR=''${XDG_STATE_HOME}/nix/profiles/home-manager
    declare -r VARS_FILE=''${HM_DIR}/home-path/etc/profile.d/hm-session-vars.sh

    [[ ! -d ''${HM_DIR} ]] && echo "Home Manager directory not found" && exit 1
    [[ ! -d ''${EXPORT_DIR} ]] && echo "Export directory not found" && exit 1

    chmod -R u+rw "''${EXPORT_DIR}"
    cp -rLf "''${HM_DIR}"/home-files/. "''${EXPORT_DIR}"
    chmod -R u+rw "''${EXPORT_DIR}"

    cp -f "''${VARS_FILE}" "''${EXPORT_DIR}"/.profile
    sed -i '/LOCALE_ARCHIVE/d' "''${EXPORT_DIR}"/.profile

    ignore=(
        ".config/direnv"
        ".config/environment.d"
    )

    for i in "''${ignore[@]}"; do
        rm -rf "''${EXPORT_DIR:?}"/"''${i}"
    done

    find "''${EXPORT_DIR}" -type f -exec sed -i 's|/nix/store/[a-z0-9]*-[^/]*/bin/||g' {} +

    sed -i '/icon_path=/d' "''${EXPORT_DIR}"/.config/dunst/dunstrc

    sed -i '/@import/d' "''${EXPORT_DIR}"/.config/gtk-4.0/gtk.css
  '';
}
