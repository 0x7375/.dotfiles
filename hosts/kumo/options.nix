{
  me = {
    hostname = "kumo";
    user = "nixos";
    secrets.enable = true;
    boot.enable = false;
    network.enable = false;
    keyd.enable = false;
  };
}
