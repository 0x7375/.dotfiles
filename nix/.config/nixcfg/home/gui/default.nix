{ myLib, ... }:

{
  imports = [
    ./default
  ] ++ (myLib.filesIn ./x11);

  xsession.numlock.enable = true;
}
