{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
  programs.feh = {
    enable = true;
    keybindings = {
      toggle_keep_vp = null;
      next_img = "C-k";
      prev_img = "C-j";
      scroll_left = "h";
      scroll_right = "l";
      scroll_up = "k";
      scroll_down = "j";
      zoom_in = "K";
      zoom_out = "J";
      delete = "D";
    };
    buttons = {
      zoom_in = 4;
      zoom_out = 5;
    };
  };
}
