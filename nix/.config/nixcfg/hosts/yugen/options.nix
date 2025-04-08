{
  me = {
    hostname = "yugen";
    refreshRate = 240;
    secrets.enable = true;
    syncthing-client.enable = true;
    gui = {
      enable = true;
      bundles = {
        postgresql.enable = true;
        neo4j.enable = false;
        gaming.enable = false;
        gns3.enable = true;
      };
    };
    devPkgs.enable = true;
  };
}
