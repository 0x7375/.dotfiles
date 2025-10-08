{
  config,
  myLib,
  lib,
  ...
}:

let
  rgba = color: alpha: "rgba(${color}${alpha})";
  inherit (myLib) hex;
in
lib.mkIf (config.me.gui.displayServer == "wayland") {
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        no_fade_in = true;
        hide_cursor = true;
        ignore_empty_input = true;
        text_trim = true;
        fail_timeout = 1000;
      };

      background.color = rgba hex.bg0_dark "ff";
      animations.enabled = false;
      input-field = {
        size = "350, 60";
        outline_thickness = 0;
        outer_color = rgba hex.bg0_dark "ff";
        check_color = rgba hex.bg0_dark "ff";
        fail_color = rgba hex.bg0_dark "ff";
        inner_color = rgba hex.bg0_dark "ff";
        font_color = rgba hex.fg0 "ff";
        fade_on_empty = false;
        fade_timeout = 0;
        dots_size = 0.3;
        dots_spacing = 1;
        dots_center = false;
        dots_fade_time = 0;
        dots_text_format = "*";
        font_family = "Mononoki Nerd Font";
        placeholder_text = "";
      };
    };
  };
}
