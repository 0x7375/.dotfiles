{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraLuaPackages = ps: [ ps.magick ];
    extraPackages = [ pkgs.imagemagick ];
  };

  home.packages = with pkgs; [
    tree-sitter

    # copilot chat
    lua54Packages.tiktoken_core
    lynx
    # peek.nvim
    deno
    # copilot
    nodejs
    legcord

    lua5_1
    luarocks
  ];
}
