{
  flake.modules.generic.dev =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        gnumake
        jq
        # karabiner
        nodejs_24
      ];
    };

  flake.modules.nixos.dev =
    { pkgs, ... }:
    {
      packages = with pkgs; [
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
      ];
    };
}
