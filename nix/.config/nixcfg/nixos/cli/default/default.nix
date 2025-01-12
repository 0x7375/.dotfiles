{ myLib, ... }:

{
  imports =
    [ ]
    ++ (myLib.filesIn ./environment)
    ++ (myLib.filesIn ./systemd-services)
    ++ (myLib.filesIn ./default);
}
