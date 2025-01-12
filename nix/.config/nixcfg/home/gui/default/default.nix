{ myLib, ... }:

{
  imports =
    [ ]
    ++ (myLib.filesIn ./xdg)
    ++ (myLib.filesIn ./default)
    ++ (myLib.filesIn ./programs)
    ++ (myLib.filesIn ./services);
}
