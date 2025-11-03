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
    packages = with pkgs; [
      inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default

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

    # systemd.user.tmpfiles.rules = [
    #   "L /home/${config.me.user}/.config/nvim - - - - ${config.me.flakeDir}/nvim"
    # ];

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
