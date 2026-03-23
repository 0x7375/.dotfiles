{
  me = {
    vpnPeer.enable = true;
    secrets = {
      enable = true;
      tpm.enable = true;
    };
    syncthing.client.enable = true;
    # boot.debug.enable = false;
    boot.encryption.enable = true;
    btrfs.enable = true;
    wm = {
      enable = true;
      displayServer = "wayland";
      refreshRate = 240;
    };
    dev.enable = true;
  };
}
