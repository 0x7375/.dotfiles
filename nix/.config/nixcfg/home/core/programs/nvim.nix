{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    # extraLuaPackages = ps: [ ps.magick ];
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];
    extraPackages = with pkgs; [
      # image.nvim
      # imagemagick
      # lua5_1
      # luarocks

      gnumake

      # tree-sitter

      # copilot chat
      lua54Packages.tiktoken_core
      lynx

      # copilot
      nodejs

      # peek.nvim
      deno
    ];
  };
}
