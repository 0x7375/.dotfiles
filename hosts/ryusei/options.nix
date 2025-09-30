{
  me = {
    secrets.enable = true;
    hostname = "ryusei";
    syncthing-client.enable = true;
    boot.debug.enable = false;
    btrfs.enable = true;
    gui = {
      enable = true;
      bundles = {
        virtualBox.enable = true;
        gaming.enable = false;
      };
    };
    devPkgs.enable = true;
    minecraft.enable = false;
  };
}
