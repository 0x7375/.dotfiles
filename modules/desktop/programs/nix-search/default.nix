{
  flake.modules.generic.desktop =
    {
      pkgs,
      lib,
      inputs,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      packages = [ pkgs.unstable.nix-search-tv ];

      hj.xdg.config.files."nix-search-tv/config.json" = {
        generator = lib.generators.toJSON { };
        value = {
          indexes = [
            "nixpkgs"
            "nixos"
            "home-manager"
            "nur"
            "noogle"
            "darwin"
          ];
          experimental.options_file.hjem =
            inputs.hjem.packages.${system}.docs-json + "/share/doc/hjem/options.json";
        };
      };

      programs.tmux.extraConfig = # tmux
        ''
          bind-key m new-window ${lib.getExe (pkgs.writeShellScriptBin "nst" (builtins.readFile ./nix-search-fzf.sh))}
        '';

      # clone repos to allow for an "open source locally" bind
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
    };
}
