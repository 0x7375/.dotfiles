{
  flake.darwin.mach = {
    me = rec {
      keyd.enable = false;
      secrets.enable = true;
      vpnPeer.enable = true;
      wm = {
        enable = true;
        terminal = {
          name = "alacritty";
          font.size = 22;
        };
        displayServer = "macos";
      };
      home = "/Users/ayko";
      hostname = "mach";
      flakeDir = home + "/.config/nixcfg";
      boot.enable = false;
      dev.enable = true;
    };
  };
}
