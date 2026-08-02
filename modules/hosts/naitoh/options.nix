{
  flake.modules.nixos.naitoh = {
    me = {
      tpm.enable = true;
      boot.debug.enable = true;
      # desktop = {
      #   scaling = 1.2;
      #   barFontSize = 11;
      # };
    };
  };
}
