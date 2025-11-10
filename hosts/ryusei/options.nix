{
  me = {
    secrets.enable = true;
    hostname = "ryusei";
    syncthing-client.enable = true;
    boot.debug.enable = false;
    btrfs.enable = true;
    desktop = {
      enable = true;
      displayServer = "xorg";
      optional = {
        virtualBox.enable = true;
        gaming.enable = true;
      };
    };
    devPkgs.enable = true;
    minecraft.enable = false;
  };
}
