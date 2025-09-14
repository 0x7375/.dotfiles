{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    scripts.nd
    scripts.dump-dotfiles
    nix-output-monitor
    wireguard-tools
    keyd
    nixd
    stow
    fzf
    gcc
    unzip
    (openssl.override { withZlib = true; })
    nixpkgs-fmt
  ];
}
