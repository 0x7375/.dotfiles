{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable {
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "${config.me.wm.font} Nerd Font" ];
        sansSerif = [ "Lexend" ];
      };
    };

    packages = with pkgs; [
      fonts.CartographCF
      fonts.InconsolataNF
      font-awesome
      nerd-fonts.mononoki
      nerd-fonts._0xproto
      nerd-fonts.jetbrains-mono
      lexend
      nerd-fonts.fira-code
      nerd-fonts.terminess-ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
