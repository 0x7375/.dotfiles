{
  myLib,
  lib,
  config,
  ...
}:

let
  colors = palette: ''
    *font: ${config.me.gui.font} Nerd Font:size=18
    *font2: ${config.me.gui.font} Nerd Font:size=18
    *padding: 20

    *bg0_dark: ${palette.bg0_dark}
    *bg0: ${palette.bg0}
    *bg1: ${palette.bg1}
    *bg2: ${palette.bg2}
    *bg3: ${palette.bg3}
    *fg4: ${palette.fg4}
    *fg3: ${palette.fg3}
    *fg2: ${palette.fg2}
    *fg1: ${palette.fg1}
    *fg0: ${palette.fg0}
    *red: ${palette.red}
    *green: ${palette.green}
    *yellow: ${palette.yellow}
    *cyan: ${palette.cyan}
    *blue: ${palette.blue}
    *magenta: ${palette.magenta}
    *orange: ${palette.orange}
  '';
in
lib.mkIf (config.me.gui.displayServer == "xorg") {
  hj.xdg.config.files."X11/dark".text = colors myLib.palette;
  hj.xdg.config.files."X11/light".text = colors myLib.light_palette;

  systemd.user.tmpfiles.rules =
    let
      xresources = "/home/${config.me.user}/.config/X11";
    in
    [
      "L ${xresources}/xresources - - - - ${xresources}/dark"
    ];
}
