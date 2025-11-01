{
  pkgs,
  lib,
  system,
  inputs,
  ...
}:

let
  hjemOptions = inputs.hjem.packages.${system}.docs-json;
  spicetifyOptions =
    inputs.spicetify-nix.legacyPackages.${system}.docs.optionsJSON
    + /share/doc/nixos/options.json;
  wslOptions =
    inputs.nixos-wsl.packages.${system}.docs.optionsDoc.optionsJSON
    + /share/doc/nixos/options.json;
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
        spicetify = "${spicetifyOptions}";
        wsl = "${wslOptions}";
        hjem = "${hjemOptions}";
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
