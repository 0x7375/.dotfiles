{ lib, config, ... }:

lib.mkIf (config.me.gui.displayServer == "wayland") {
  programs.pqiv = {
    enable = true;
    settings = {
      options = {
        hide-info-box = true;
      };
    };
    extraConfig = ''
      [keybindings]
      <Control>j { goto_file_relative(-1) }
      <Control>k { goto_file_relative(1) }
      <Shift>j { set_scale_level_relative(0.9) }
      <Shift>k { set_scale_level_relative(1.1) }
      h { shift_x(25) }
      j { shift_y(-25) }
      k { shift_y(25) }
      l { shift_x(-25) }
    '';
  };
}
