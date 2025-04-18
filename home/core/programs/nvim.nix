{
  config,
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

  systemd.user.tmpfiles.rules = [
    "L /home/${config.me.user}/.config/nvim - - - - ${config.me.flakeDir}/nvim"
  ];

  # https://github.com/nix-community/home-manager/issues/676#issuecomment-1595795685
  # lib.meta = {
  #   configPath = config.me.flakeDir;
  #   mkMutableSymlink =
  #     path:
  #     config.lib.file.mkOutOfStoreSymlink (
  #       config.lib.meta.configPath + lib.removePrefix (toString inputs.self) (toString path)
  #     );
  # };
  #
  # xdg.configFile."nvim" = {
  #   source = config.lib.meta.mkMutableSymlink ../../../nvim;
  # };
}
