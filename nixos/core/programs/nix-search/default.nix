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

  hj.xdg.config.files."zsh/widgets.zsh".text =
    lib.mkAfter
      # bash
      ''
        nix-search-widget() {
          LBUFFER="nst"
          zle accept-line
        }
        zle -N nix-search-widget
      '';

  hj.xdg.config.files."zsh/bindings.zsh".text =
    lib.mkAfter
      # bash
      ''
        bindkey '^G' nix-search-widget
      '';

  programs.tmux.extraConfig = # tmux
    ''
      # bind-key m run-shell "tmux popup -E -w 80% -h 80% ${lib.getExe nst} || true"
      bind-key m new-window ${lib.getExe nst}
    '';
}
