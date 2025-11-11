{ pkgs, ... }:

{
  packages = with pkgs; [
    scripts.dump-dotfiles
    wireguard-tools
    stow
    gcc
    unzip
    (openssl.override { withZlib = true; })
    ncdu
    wget
    age
    bc
    efibootmgr
    ripgrep
    fd
    tlrc
    trash-cli
    tree
    termdown
    jrl

    nix-melt
    nix-output-monitor
    scripts.nd
    dix
  ];
}
