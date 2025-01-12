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
        gaming.enable = true;
      };
    };
    devPkgs.enable = true;
  };
}
