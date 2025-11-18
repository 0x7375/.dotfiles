{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.wm.enable {
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

  hj.xdg.config.files."mpv/input.conf".text = ''
    h seek -5
    l seek 5
    H seek -1 exact
    L seek 1 exact

    j multiply speed 0.9
    k multiply speed 1.1

    p cycle pause
  '';
}
