{ inputs, self, ... }:

let
  neovimBase = pkgs: configDir: {
    inherit pkgs;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings.config_directory = configDir;

    extraPackages = with pkgs; [
      nixd
      nixfmt
      shfmt

      tree-sitter
      gnumake

      lua54Packages.tiktoken_core
      lynx
      # peek.nvim
      deno
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
