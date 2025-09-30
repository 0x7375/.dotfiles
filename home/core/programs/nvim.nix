{
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

    systemd.user.tmpfiles.rules = [
      "L /home/${config.me.user}/.config/nvim - - - - ${config.me.flakeDir}/nvim"
    ];
  }
  (lib.mkIf config.me.secrets.enable {
    sops.secrets.copilot = {
      sopsFile = "${secrets}/copilot.json";
      format = "json";
      key = "";
      path = "/home/${config.me.user}/.config/github-copilot/apps.json";
    };
  })
]
