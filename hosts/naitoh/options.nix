{
  me = {
    secrets.enable = true;
    syncthing-client.enable = true;
    boot.debug.enable = false;
    btrfs.enable = true;
    vpnPeer.enable = true;
    wm = {
      enable = true;
      displayServer = "xorg";
      optional = {
        virtualBox.enable = true;
        gaming.enable = false;
      };
    };
    dev.enable = true;
    minecraft.enable = false;
  };
}
