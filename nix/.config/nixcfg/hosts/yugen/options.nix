{
  me = {
    hostname = "yugen";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53 yugen";
    refreshRate = 240;
    secrets.enable = true;
    syncthing-client.enable = true;
    gui = {
      enable = true;
      bundles = {
        postgresql.enable = true;
        neo4j.enable = false;
        gaming.enable = true;
      };
    };
    devPkgs.enable = true;
  };
}
