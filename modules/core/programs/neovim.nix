{ inputs, self, ... }:

let
  neovimBase =
    {
      pkgs,
      configDir,
      unfree ? false,
    }:
    {
      inherit pkgs;
      settings.config_directory = configDir;

      package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

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

      extraPackages =
        with pkgs;
        [
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
          bash-language-server
          emmet-language-server
          vscode-langservers-extracted
          gopls
          typescript-language-server
          texlab
          sqls
          ruff
          pyright
          phpactor

          # Formatters
          nixfmt
          shfmt
          phpPackages.php-codesniffer
          typstyle
          libxml2

          # Linters
          shellcheck
        ]
        ++ (lib.optionals unfree [
          pkgs.intelephense
        ]);
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.neovim =
        (inputs.wrappers.wrappers.neovim.apply (neovimBase {
          inherit pkgs;
          configDir = ../../../nvim;
        })).wrapper;
    };

  flake.shared.core =
    { pkgs, config, ... }:
    {
      unfree-packages = [ "intelephense" ];

      packages = [
        (inputs.wrappers.wrappers.neovim.apply (neovimBase {
          inherit pkgs;
          configDir = "${config.me.flakeDir}/nvim";
          unfree = true;
        })).wrapper
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
