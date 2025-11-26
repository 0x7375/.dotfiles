{
  me = {
    refreshRate = 240;
    secrets.enable = true;
    syncthing-client.enable = true;
    # boot.debug.enable = false;
    btrfs.enable = true;
    wm = {
      enable = true;
      displayServer = "xorg";
      optional = {
        postgresql.enable = false;
        neo4j.enable = false;
        gaming.enable = true;
      };
    };
    dev.enable = true;
  };
}
