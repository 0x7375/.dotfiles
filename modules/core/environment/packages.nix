{ pkgs, ... }:

{
  packages =
    with pkgs;
    [
      my.dump-dotfiles
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
      my.nd
      my.nlink
      dix
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      efibootmgr
    ]);
}
