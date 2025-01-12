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
      (nerdfonts.override {
        fonts = [
          "Mononoki"
          "Ubuntu"
          "FiraCode"
        ];
      })
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
  };
}
