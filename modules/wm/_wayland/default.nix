{
  lib,
  config,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "wayland") {
  # services.kanshi.enable = true;

  vars = {
    NIXOS_OZONE_WL = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
