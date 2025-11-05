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
    programs.neovim = {
      enable = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
      withNodeJs = true; # for copilot
    };

    packages = with pkgs; [
      tree-sitter
      gnumake

      lua54Packages.tiktoken_core
      lynx

      # peek.nvim
      deno
    ];

    hj.xdg.config.files."nvim".source = "${config.me.flakeDir}/nvim";
  }
  (lib.mkIf config.me.secrets.enable {
    sops.secrets.copilot = {
      sopsFile = "${secrets}/copilot.json";
      owner = config.me.user;
      format = "json";
      key = "";
      path = "/home/${config.me.user}/.config/github-copilot/apps.json";
    };
  })
]
