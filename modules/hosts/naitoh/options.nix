{
  flake.nixos.naitoh = {
    me = {
      tpm.enable = true;
      boot.debug.enable = false;
      boot.encryption.enable = true;
      wm = {
        enable = true;
        scaling = 1.2;
        displayServer = "wayland";
        optional.virtualBox.enable = true;
        barFontSize = 11;
      };
    };
  };
}
