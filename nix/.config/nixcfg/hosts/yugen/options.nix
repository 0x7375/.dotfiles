{ myLib, ... }:

{
  me = {
    hostname = "yugen";
    refreshRate = 240;
    secrets.enable = true;
    syncthing-client.enable = true;
    # boot.debug.enable = false;
    allowedIPsRootLogin = "${myLib.network.lan.addr.laptop}";
    gui = {
      enable = true;
      bundles = {
        postgresql.enable = false;
        neo4j.enable = false;
        gaming.enable = false;
        gns3.enable = false;
      };
    };
    devPkgs.enable = true;
  };
}
