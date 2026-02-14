{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.dev.enable {
  packages = with pkgs; [
    gnumake
    deno

    go
    delve

    # nodePackages.eas-cli

    nodejs_24

    # haskell
    # ghc

    # php
    php
    # nodePackages.intelephense

    # java
    zulu

    # c
    clang-tools
    gcc
    bear
    gdb

    python3
    taplo
    jq
  ];
}
