{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    scripts.nd
    scripts.dump-dotfiles
    nix-output-monitor
    keyd
    nixd
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
    tldr
    trash-cli
    tree
    nixpkgs-fmt
  ];
}
