{
  flake.nixos.isoImg = {
    me = {
      user = "nixos";
      boot.enable = false;
      secrets.enable = false;
      network.enable = false;
    };
  };
}
