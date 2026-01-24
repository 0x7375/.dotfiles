{
  me = rec {
    secrets.enable = true;
    wm = {
      terminal = "alacritty";
      enable = true;
      displayServer = "macos";
    };
    home = "/Users/ayko";
    hostname = "mach";
    flakeDir = home + "/.config/nixcfg";
    boot.enable = false;
    dev.enable = true;
  };
}
