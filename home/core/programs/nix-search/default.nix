{
  pkgs,
  lib,
  system,
  inputs,
  ...
}:

let
  mkOpts =
    system: module:
    inputs.unf.lib.json {
      self = inputs.self;
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      modules = [ module ];
    };

  sopsOptions = mkOpts system inputs.sops-nix.nixosModules.default;
  spicetifyOptions =
    inputs.spicetify-nix.legacyPackages.${system}.docs.optionsJSON
    + /share/doc/nixos/options.json;
  wslOptions =
    inputs.nixos-wsl.packages.${system}.docs.optionsDoc.optionsJSON
    + /share/doc/nixos/options.json;
  nst = (pkgs.writeShellScriptBin "nst" (builtins.readFile ./nix-search-fzf.sh));
in
{
  programs.nix-search-tv = {
    enable = true;
    settings = {
      experimental.options_file = {
        spicetify = "${spicetifyOptions}";
        sops = "${sopsOptions}";
        wsl = "${wslOptions}";
      };
    };
  };

  home.packages = [ nst ];

  xdg.configFile."zsh/widgets.zsh".text =
    lib.mkAfter
      # bash
      ''
        nix-search-widget() {
          LBUFFER="nst"
          zle accept-line
        }
        zle -N nix-search-widget
      '';

  xdg.configFile."zsh/bindings.zsh".text =
    lib.mkAfter
      # bash
      ''
        bindkey '^G' nix-search-widget
      '';

  programs.tmux.extraConfig = # tmux
    ''
      bind-key m run-shell "tmux popup -E -w 80% -h 80% ${nst}/bin/nst || true"
    '';
}
