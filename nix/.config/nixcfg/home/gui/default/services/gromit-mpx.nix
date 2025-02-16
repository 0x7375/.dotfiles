{
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  services.gromit-mpx = {
    enable = true;
    hotKey = null;
    undoKey = null;
  };
}
