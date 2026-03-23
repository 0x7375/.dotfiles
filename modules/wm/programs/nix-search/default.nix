{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  nst = (pkgs.writeShellScriptBin "nst" (builtins.readFile ./nix-search-fzf.sh));
in
lib.mkIf config.me.wm.enable {
  packages = [
    (pkgs.nix-search-tv.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = old.src.owner;
        repo = old.src.repo;
        rev = "73a34372b15b3824586b3f65c22c4ff8f0eb4c2c";
        hash = "sha256-vWKMGj2fBUbsAvwoYjgT+L4hH0A96u4rDOaT0wnj7iw=";
      };
      vendorHash = "sha256-SSKDo4A8Nhvylghrw6d7CdHpZ7jObEr5V3r0Y9cH80Y=";
    }))
    nst
  ];

  hj.xdg.config.files."nix-search-tv/config.json" = {
    generator = lib.generators.toJSON { };
    value = {
      experimental.options_file = {
        hjem = inputs.hjem.packages.${system}.docs-json;
      };
    };
  };

  programs.tmux.extraConfig = # tmux
    ''
      bind-key m new-window ${lib.getExe nst}
    '';

  userActivation = # bash
    ''
      export PATH=${pkgs.git}/bin:$PATH

      mkdir -p $HOME/repos
      cd $HOME/repos

      SHALLOW=("--depth=1" "--single-branch" "--no-tags")
      [[ ! -d ~/repos/home-manager ]] && echo "Cloning home-manager..." && git clone https://github.com/nix-community/home-manager "''${SHALLOW[@]}"
      [[ ! -d ~/repos/nix-darwin ]] && echo "Cloning nix-darwin..." && git clone https://github.com/nix-darwin/nix-darwin "''${SHALLOW[@]}"
      [[ ! -d ~/repos/nixpkgs ]] && echo "Cloning nixpkgs..." && git clone https://github.com/nixos/nixpkgs "''${SHALLOW[@]}"
      [[ ! -d ~/repos/nur-combined ]] && echo "Cloning nix-darwin..." && git clone https://github.com/nix-community/nur-combined "''${SHALLOW[@]}"
    '';
}
