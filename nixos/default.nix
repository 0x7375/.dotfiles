{
  pkgs,
  inputs,
  myLib,
  ...
}:

{
  imports = [
    ../lib
  ]
  ++ myLib.filesIn ../modules/nixos;

  environment.etc.nixcfg.source = pkgs.lib.cleanSource inputs.self;
}
