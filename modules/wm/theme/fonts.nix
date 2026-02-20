{
  config,
  lib,
  pkgs,
  mkNixos,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
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
      font-awesome
      nerd-fonts.mononoki
      lexend
      nerd-fonts.terminess-ttf
      nerd-fonts._0xproto
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
})
