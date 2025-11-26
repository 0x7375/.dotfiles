{
  me = {
    secrets.enable = true;
    syncthing-client.enable = true;
    boot.debug.enable = false;
    btrfs.enable = true;
    wm = {
      enable = true;
      displayServer = "xorg";
      optional = {
        virtualBox.enable = true;
        gaming.enable = true;
      };
    };
    dev.enable = true;
    minecraft.enable = false;
  };
}
