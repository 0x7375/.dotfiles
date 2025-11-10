{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.desktop.enable {
  packages = [ pkgs.mpv ];

  hj.xdg.config.files."mpv/mpv.conf".text = # ini
    ''
      blend-subtitles=%2%no
      sub-blur=%8%2.250000
      sub-border-color=%7%#000000
      sub-border-size=%8%0.100000
      sub-font=%9%Noto Sans
      sub-font-size=%2%30
      sub-pos=%2%95
      sub-shadow-color=%7%#000000
      sub-shadow-offset=%1%0
    '';
}
