{
  flake.modules.nixos.naitoh = {
    me = {
      tpm.enable = true;
      boot = {
        encryption.enable = true;
        secureBoot.enable = true;
      };
      desktop = {
        scaling = 1.2;
        barFontSize = 11;
      };
    };
  };
}
