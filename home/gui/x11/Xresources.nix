{
  myLib,
  lib,
  config,
  ...
}:

let
  palette = myLib.palette;
in
lib.mkIf (config.me.gui.displayServer == "xorg") {
  xresources = {
    path = "/home/${config.me.user}/.config/X11/xresources";
    properties = {
      "st.font" = "${config.me.gui.font} Nerd Font:style=Bold:size=20";
      "st.font2" = "${config.me.gui.font} Nerd Font:style=Bold:size=20";
      "st.cursorColor" = palette.fg0;
      "st.background" = palette.bg0;
      "st.foreground" = palette.fg0;
      "st.normalBlack" = palette.bg3;
      "st.normalRed" = palette.red;
      "st.normalGreen" = palette.green;
      "st.normalYellow" = palette.yellow;
      "st.normalBlue" = palette.blue;
      "st.normalMagenta" = palette.magenta;
      "st.normalCyan" = palette.cyan;
      "st.normalWhite" = palette.fg3;
      "st.brightBlack" = palette.fg4;
      "st.brightRed" = palette.red;
      "st.brightGreen" = palette.green;
      "st.brightYellow" = palette.yellow;
      "st.brightBlue" = palette.blue;
      "st.brightMagenta" = palette.magenta;
      "st.brightCyan" = palette.cyan;
      "st.brightWhite" = palette.fg0;
    };
  };
}
