{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
  services = {
    # make physical playback buttons work
    mpris-proxy.enable = true;

    playerctld.enable = true;

    copyq.enable = true;
  };
}
