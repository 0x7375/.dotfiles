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
      scaling = 1.2;
      displayServer = "wayland";
      optional.virtualBox.enable = true;
      barFontSize = 11;
    };
    dev.enable = true;
    minecraft.enable = false;
  };
}
