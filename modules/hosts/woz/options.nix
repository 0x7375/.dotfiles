{
  flake.modules.nixos.woz = {
    me = {
      boot.encryption.enable = true;
      desktop = {
        scaling = 1.6;
        barFontSize = 11;
      };
    };
  };
}
