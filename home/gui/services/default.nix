{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  services = {
    # make physical playback buttons work
    mpris-proxy.enable = true;

    playerctld.enable = true;

    easyeffects = {
      enable = true;
      preset = "default";
      extraPresets.default = builtins.fromJSON (builtins.readFile ./easyeffects.json);
    };

    polkit-gnome.enable = true;
  };
}
