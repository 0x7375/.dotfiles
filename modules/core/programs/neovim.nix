{ inputs, self, ... }:

let
  neovimBase = pkgs: configDir: {
    inherit pkgs;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings.config_directory = configDir;

    specs.treesitter = {
      lazy = false;
      data = [
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (
          p: with p; [
            c
            go
            java
            python
            sql
            nix
            bash
            vim
            vimdoc
            query
            regex
            markdown
            markdown_inline
            gitignore
            gitcommit
            cmake
            make
            diff
            comment
            tmux
            hyprlang
            xcompose
            git_config
            json
            jsonc
            yaml
            xml
            ini
            toml
            html
            css
            javascript
            tsx
            typescript
            php
            graphql
            latex
            typst
          ]
        ))
      ];
    };

    extraPackages = with pkgs; [
      tree-sitter
      gnumake

      lua54Packages.tiktoken_core
      lynx
      # peek.nvim
      deno

      # LSPs
      lua-language-server
      nixd
      jdt-language-server

      # Formatters
      nixfmt
      shfmt
    ];
  };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.neovim = (inputs.wrappers.wrappers.neovim.apply (neovimBase pkgs ../../../nvim)).wrapper;
    };

  flake.shared.core =
    { pkgs, config, ... }:
    {
      packages = [
        (inputs.wrappers.wrappers.neovim.apply (neovimBase pkgs "${config.me.flakeDir}/nvim")).wrapper
      ];
    };

  flake.nixos.core = {
    xdg.mimeApps.defaultApplications = self.lib.mapMimeEntries [
      "text/plain"
      "text/markdown"
      "text/x-java"
      "text/x-haskell"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-makefile"
      "text/x-python"
      "text/x-log"
      "text/x-readme"
      "text/x-patch"
      "text/css"
      "application/x-php"
      "application/x-desktop"
      "application/json"
      "application/xml"
      "application/x-shellscript"
    ] "nvim";
  };
}
