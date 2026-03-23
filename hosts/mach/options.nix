{
  me = rec {
    keyd.enable = false;
    secrets.enable = true;
    vpnPeer.enable = true;
    wm = {
      terminal = "alacritty";
      enable = true;
      terminal.font.size = 22;
      displayServer = "macos";
    };
    home = "/Users/ayko";
    hostname = "mach";
    flakeDir = home + "/.config/nixcfg";
    boot.enable = false;
    dev.enable = true;
  };
}
