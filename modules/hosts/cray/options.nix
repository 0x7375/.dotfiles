{
  flake.nixos.cray = {
    me = {
      tpm.enable = true;
      boot.encryption.enable = true;
      desktop.refreshRate = 240;
    };
  };
}
