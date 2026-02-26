{
  me = {
    vpnPeer.enable = true;
    secrets = {
      enable = true;
      tpm = {
        enable = true;
        file = ./keys.txt;
      };
    };
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
