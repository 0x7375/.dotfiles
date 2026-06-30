{ inputs, self, ... }:

let
  mkNeovim =
    {
      pkgs,
      lsp ? true,
      unfree ? false,
    }:
    inputs.mnw.lib.wrap pkgs {
      neovim =
        inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neovim-unwrapped.overrideAttrs
          (_: {
            doCheck = false;
            doInstallCheck = false;
            patches = [
              ./allow_showcmdloc_winbar.patch
            ];
          });

      initLua = builtins.readFile ./init.lua;

      providers = {
        ruby.enable = true;
        python3.enable = true;
        nodeJs.enable = true;
        perl.enable = true;
      };

      plugins = {
        dev.config = {
          pure = "${./../../../../nvim}";
          impure = "~/.config/nixcfg/nvim";
        };

        start =
          with pkgs.vimPlugins;
          [
            # ui
            cloak-nvim
            rainbow-delimiters-nvim
            gitsigns-nvim
            nvim-highlight-colors

            # lsp
            nvim-lspconfig
            friendly-snippets
            luasnip
            conform-nvim
            blink-cmp
            neogen
            lazydev-nvim
            nvim-lint

            # nav
            fzf-lua
            oil-nvim
            harpoon2
            plenary-nvim

            # tools
            live-command-nvim
            undotree
            vim-fugitive
            codediff-nvim
            grug-far-nvim
            orgmode

            # actions
            treesj
            dial-nvim
            mini-move
            nvim-surround
            nvim-ts-autotag
            vim-indent-object
            nvim-treesitter-textobjects
          ]
          ++ nvim-treesitter.withAllGrammars.dependencies
          ++ pkgs.lib.optionals unfree (
            with pkgs.vimPlugins;
            [
              ReplaceWithRegister
              vim-wordmotion
            ]
          );
      };

      extraBinPath =
        pkgs.lib.optionals lsp (
          with pkgs;
          [
            tree-sitter
            gnumake
            cargo
            rustc

            # LSPs
            lua-language-server
            nixd
            typescript-language-server
            jdt-language-server
            bash-language-server
            emmet-language-server
            vscode-langservers-extracted
            gopls
            texlab
            sqls
            ruff
            pyright
            phpactor
            mpls

            # Formatters
            nixfmt
            stylua
            typstyle
            shfmt
            phpPackages.php-codesniffer
            libxml2

            # Linters
            shellcheck
            statix
            deadnix
          ]
        )
        ++ pkgs.lib.optionals unfree [ pkgs.intelephense ];
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.neovim = mkNeovim { inherit pkgs; };
    };

  flake.modules.generic.core =
    {
      pkgs,
      ...
    }:
    {
      packages = [
        pkgs.my.fossify
        (mkNeovim {
          inherit pkgs;
          lsp = false;
          unfree = true;
        })
      ];

      unfree-packages = [
        "ReplaceWithRegister"
        "vim-wordmotion"
      ];
    };

  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      persistUser.directories = [
        ".cache/nvim"
        ".local/share/nvim"
        ".local/state/nvim"
      ];

      unfree-packages = [
        "intelephense"
      ];

      packages = [
        (mkNeovim {
          inherit pkgs;
          unfree = true;
        }).devMode
      ];
    };

  flake.modules.nixos.core = {
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
