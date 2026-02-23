{
  inputs,
  config,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      neovim = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
    })
  ];

  packages = with pkgs; [
    neovim

    nixd
    nixfmt
    shfmt

    # tree-sitter
    tree-sitter
    gnumake

    lua54Packages.tiktoken_core
    lynx

    # peek.nvim
    deno
  ];

  hj.xdg.config.files."nvim".source = "${config.me.flakeDir}/nvim";
}
