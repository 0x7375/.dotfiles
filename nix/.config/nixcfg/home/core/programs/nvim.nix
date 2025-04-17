{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  # mkSymlinkAttrs = import (myLib.fromRoot "lib/mkSymlinkAttrs.nix") {
  #   inherit pkgs;
  #   runtimeRoot = config.me.flakeDir;
  # };
  createSymlink = localPath: config.lib.file.mkOutOfStoreSymlink;
in
{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      tree-sitter
      gnumake

      # copilot chat
      lua54Packages.tiktoken_core
      lynx

      # copilot
      nodejs

      # peek.nvim
      deno
    ];
  };

  # black magic
  # https://github.com/nix-community/home-manager/issues/676#issuecomment-1595795685
  lib.meta = {
    configPath = config.me.flakeDir;
    mkMutableSymlink =
      path:
      config.lib.file.mkOutOfStoreSymlink (
        config.lib.meta.configPath + lib.removePrefix (toString inputs.self) (toString path)
      );
  };

  home.file.".config/nvim" = {
    source = config.lib.meta.mkMutableSymlink ../../../nvim;
  };
}
