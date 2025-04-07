{ myLib, ... }:

{
  imports = [
    ../lib
  ] ++ myLib.filesIn ../modules/nixos;
}
