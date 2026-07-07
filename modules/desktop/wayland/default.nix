{
  flake.modules.nixos.wayland = {
    vars = {
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland,x11"; # without ,x11 some apps just don't load I think?
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}
