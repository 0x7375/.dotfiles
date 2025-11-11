{
  config,
  lib,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "wayland") {
  programs.hyprland.enable = true;

  vars = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
