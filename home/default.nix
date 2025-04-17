{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:

{
  imports = [
    ../lib
  ] ++ (myLib.filesIn ../modules/home);

  xdg.configFile."nixpkgs/config.nix".text = # nix
    ''
      {
        allowUnfree = true;
      }
    '';

  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.use-xdg-base-directories = true;

  home.username = config.me.user;
  home.homeDirectory = "/home/${config.me.user}";

  home.activation.initialSetup = lib.mkIf config.me.secrets.enable (
    lib.hm.dag.entryAfter [ "writeBoundary" ]
      # bash
      ''
        [[ ! -e ${config.me.flakeDir} ]] && {
          run ${pkgs.git}/bin/git -c core.sshCommand="${pkgs.openssh}/bin/ssh" clone codeberg:0xB0F/.dotfiles ${config.me.flakeDir}
        }

        [[ ! -L /home/${config.me.user}/.config/nvim ]] && ln -s ${config.me.flakeDir}/nvim /home/${config.me.user}/.config/nvim
      ''
  );

  home.stateVersion = "23.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
