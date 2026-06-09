{
  flake.modules.nixos.woz = {
    me = {
      boot.encryption.enable = true;
    };
  };
}
