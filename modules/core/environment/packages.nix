{ pkgs, ... }:

{
  packages =
    with pkgs;
    [
      scripts.dump-dotfiles
      wireguard-tools
      gcc
      unzip
      (openssl.override { withZlib = true; })
      ncdu
      wget
      age
      bc
      ripgrep
      fd
      tlrc
      trash-cli
      tree
      termdown

      nix-melt
      nix-output-monitor
      scripts.nd
      scripts.nlink
      dix
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      efibootmgr
    ]);
}
