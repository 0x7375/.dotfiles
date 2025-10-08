{
  lib,
  config,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "wayland") {
  services.kanshi.enable = true;
}
