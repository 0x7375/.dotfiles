{
  config,
  lib,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "wayland") {
  programs.hyprlock.enable = true;

  tinted.files.".config/hypr/hyprlock.conf" = {
    prefix = false;
    text = p: ''
      general {
        no_fade_in = true
        hide_cursor = true
        ignore_empty_input = false
        text_trim = true
        fail_timeout = 1000
      }

      background {
        color = rgba(${p.bg0_dark}ff)
      }

      animations {
        enabled = false
      }

      input-field {
        size = 350, 60
        outline_thickness = 0
        outer_color = rgba(${p.bg0_dark}ff)
        check_color = rgba(${p.bg0_dark}ff)
        fail_color = rgba(${p.bg0_dark}ff)
        inner_color = rgba(${p.bg0_dark}ff)
        font_color = rgba(${p.fg0}ff)
        fade_on_empty = false
        fade_timeout = 0
        dots_size = 0.3
        dots_spacing = 1
        dots_center = false
        dots_fade_time = 0
        dots_text_format = *
        font_family = Mononoki Nerd Font
        placeholder_text =
      }

      label {
        text = ~locked
        color = rgba(${p.fg0}ff)
        font_family = Mononoki Nerd Font
        valign = top
        halign = center
        position = 0, -10
      }
    '';
  };
}
