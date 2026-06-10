{
  flake.modules.nixos.woz = {
    me = {
      boot.encryption.enable = true;
      desktop = {
        scaling = 1.8;
        barFontSize = 11;
      };
    };
  };
}
