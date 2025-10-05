{
  me = {
    hostname = "yugen";
    refreshRate = 240;
    secrets.enable = true;
    syncthing-client.enable = true;
    # boot.debug.enable = false;
    btrfs.enable = true;
    gui = {
      enable = true;
      bundles = {
        postgresql.enable = false;
        neo4j.enable = false;
        gaming.enable = true;
      };
    };
    devPkgs.enable = true;
  };
}
