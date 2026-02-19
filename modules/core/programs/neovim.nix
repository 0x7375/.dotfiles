{
  inputs,
  lib,
  secrets,
  config,
  pkgs,
  ...
}:

lib.mkMerge [
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

      # tree-sitter
      tree-sitter
      gnumake

      lua54Packages.tiktoken_core
      lynx

      # peek.nvim
      deno

      nodejs # copilot
    ];

    hj.xdg.config.files."nvim".source = "${config.me.flakeDir}/nvim";
  }
  (lib.mkIf config.me.secrets.enable {
    sops.secrets.copilot = {
      sopsFile = "${secrets}/copilot.json";
      owner = config.me.user;
      format = "json";
      key = "";
      path = "${config.me.home}/.config/github-copilot/apps.json";
    };
  })
]
