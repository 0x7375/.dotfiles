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
        tree
        termdown
        caligula

        nix-output-monitor
        inputs.nd.packages.${pkgs.stdenv.hostPlatform.system}.default
        my.nlink
        my.dump-dotfiles
        dix
      ];
    };

  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      persistUser.directories = [
        ".cache/tlrc"
      ];

      packages = with pkgs; [
        efibootmgr
        gcc
      ];
    };
}
