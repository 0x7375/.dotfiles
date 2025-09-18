{ pkgs, ... }:

{
  home.packages = with pkgs; [
    stow
    fzf
    gcc
    ncdu
    unzip
    wget
    age
    bc
    cron
    efibootmgr
    fastfetch
    ripgrep
    fd
    tlrc
    trash-cli
    tree

    # neovim
    tree-sitter

    # copilot chat
    lua54Packages.tiktoken_core
    lynx
    # peek.nvim
    deno
    # copilot
    nodejs

    scripts.flake
  ];
}
