{
  flake.modules.darwin.mach = {
    me = rec {
      desktop.terminal.font.size = 22;
      home = "/Users/ayko";
      hostname = "mach";
      flakeDir = home + "/.config/nixcfg";
    };
  };
}
