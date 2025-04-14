{ config, pkgs, ... }:

pkgs.writeShellApplication {
  name = "setup-dotfiles";
  runtimeInputs = with pkgs; [
    git
    neovim
  ];
  text =
    let
      dot = config.me.dotfilesDir;
    in
    # bash
    ''
      green=$(tput setaf 2)
      reset=$(tput sgr0)
      dots="''${green}::''${reset}"

      if [[ ! -e "${dot}" ]]; then
        git clone codeberg:0xB0F/.dotfiles ${dot}
        pushd ${dot}/nix/.config/nixcfg; git init; mv .git .nix-git
        (
          export GIT_DIR=.nix-git
          git config user.name name; git config user.email email
          git add .; git commit -m "initial commit"
        )
        pushd ${dot} > /dev/null
        stow nix nvim

        # install config in the background
        echo "''${dots} Installing neovim plugins"
        nvim --headless "+Lazy! sync" +qa > /dev/null

        popd > /dev/null; popd > /dev/null
      else
        echo "Dotfiles already setup"
      fi
    '';
}
