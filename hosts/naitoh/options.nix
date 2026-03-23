{
  me = {
    secrets = {
      enable = true;
      tpm.enable = true;
    };
    syncthing.client.enable = true;
    boot.debug.enable = false;
    btrfs.enable = true;
    vpnPeer.enable = true;
    boot.encryption.enable = true;
    wm = {
      enable = true;
      scaling = 1.125;
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
