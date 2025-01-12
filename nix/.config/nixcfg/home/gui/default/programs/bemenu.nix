{
  myLib,
  config,
  lib,
  ...
}:

let
  palette = myLib.palette;
in
lib.mkIf config.me.gui.enable {
  programs.bemenu = {
    enable = true;

    settings = {
      border = 7;
      ignorecase = true;
      fn = "Mononoki Nerd Font ${toString myLib.bar.font-size}";
      hp = 10;
      tb = palette.bg0_dark;
      fb = palette.bg0_dark;
      nb = palette.bg0_dark;
      ab = palette.bg0_dark;
      scb = palette.bg0_dark;
      bdr = palette.bg0_dark;
      hf = palette.bg0_dark;
      nf = palette.fg0;
      tf = palette.fg0;
      ff = palette.fg0;
      hb = palette.fg0;
      sb = palette.fg0;
      cb = palette.fg0;
      cf = palette.fg0;
      sf = palette.fg0;
      af = palette.fg0;
      scf = palette.fg0;
    };
  };
}
