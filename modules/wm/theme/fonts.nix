{
  config,
  lib,
  mkNixos,
  pkgs,
  ...
}:

let
  inherit (config.me.wm) terminalFont font;
in
lib.mkIf config.me.wm.enable (mkNixos {
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ terminalFont.family ];
        sansSerif = [ font.family ];
      };
    };

    packages =
      with pkgs;
      [
        fonts.CartographCF
        font-awesome
        nerd-fonts.mononoki
        lexend
        nerd-fonts.terminess-ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ]
      ++ [
        font.package
        terminalFont.package
      ];
  };
})
