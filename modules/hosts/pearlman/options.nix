{
  flake.nixos.pearlman = {
    me = {
      secrets = {
        enable = true;
        tpm.enable = true;
      };
      boot.enable = true;
      syncthing.enable = true;
    };
  };
}
