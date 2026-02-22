{
  me = {
    secrets.enable = true;
    syncthing.client.enable = true;
    # boot.debug.enable = false;
    btrfs.enable = true;
    wm = {
      enable = true;
      displayServer = "xorg";
      refreshRate = 240;
    };
    dev.enable = true;
  };
}
