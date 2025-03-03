{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Inconsolata Nerd Font" ];
        sansSerif = [ "Ubuntu Nerd Font" ];
      };
    };

    packages = with pkgs; [
      fonts.CartographCF
      fonts.InconsolataNF
      font-awesome
      nerd-fonts.mononoki
      nerd-fonts._0xproto
      nerd-fonts.ubuntu
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
  };
}
