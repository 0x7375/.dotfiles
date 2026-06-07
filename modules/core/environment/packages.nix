{
  flake.modules.generic.core =
    { inputs, pkgs, ... }:
    {
      packages = with pkgs; [
        wireguard-tools
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
        # my.nd
        inputs.nd.packages.${pkgs.stdenv.hostPlatform.system}.default
        my.nlink
        my.dump-dotfiles
        dix
      ];
    };

  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        efibootmgr
        gcc
      ];
    };
}
