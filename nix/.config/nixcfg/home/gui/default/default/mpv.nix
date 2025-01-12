{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
  programs.mpv = {
    enable = true;
    config = {
      sub-shadow-color = "#000000";
      sub-font = "Noto Sans";
      # sub-bold = true;
      sub-pos = 95;
      blend-subtitles = false;
      sub-font-size = 30;
      sub-blur = 2.25;
      sub-border-color = "#000000";
      sub-border-size = 0.1;
      sub-shadow-offset = 0;
    };
  };
}
