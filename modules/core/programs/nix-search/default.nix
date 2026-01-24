{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  nst = (pkgs.writeShellScriptBin "nst" (builtins.readFile ./nix-search-fzf.sh));
in
{
  packages = [
    pkgs.nix-search-tv
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
}
