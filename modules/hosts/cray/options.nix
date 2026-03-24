{
  flake.nixos.cray = {
    me = {
      tpm.enable = true;
      # boot.debug.enable = false;
      boot.encryption.enable = true;
      # wm = {
      #   enable = true;
      #   displayServer = "wayland";
      #   refreshRate = 240;
      # };
    };
  };
}
