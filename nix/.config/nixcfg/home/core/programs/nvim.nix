{
  config,
  lib,
  pkgs,
  ...
}:

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

  # xdg.configFile.nvim = lib.file.mkOutOfStoreSymlink "/home/${config.me.user}/nvim";
}
