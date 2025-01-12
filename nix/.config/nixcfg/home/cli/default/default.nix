{ myLib, ... }:

{
  imports = [ ] ++ (myLib.filesIn ./default) ++ (myLib.filesIn ./programs);
}
