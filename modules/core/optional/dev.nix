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

    # haskell
    # ghc

    # php
    php
    # nodePackages.intelephense

    # java
    zulu
    ant
    maven

    # sql
    mariadb
    sqlite
    litecli

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
