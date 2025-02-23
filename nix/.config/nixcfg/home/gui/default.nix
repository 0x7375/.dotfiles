{
  myLib,
  lib,
  config,
  ...
}:

{
  imports = [
    ./default
  ] ++ (myLib.filesIn ./x11);

  config = lib.mkIf config.me.gui.enable {
    xsession.numlock.enable = true;
  };
}
