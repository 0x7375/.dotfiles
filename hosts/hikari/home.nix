{ myLib, ... }:

{
  imports = [
    ./options.nix
  ] ++ (myLib.filesIn ../../home);
}
