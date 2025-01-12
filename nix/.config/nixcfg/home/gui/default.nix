{ myLib, ... }:

{
  imports = [
    ./default
  ] ++ (myLib.filesIn ./x11);
}
