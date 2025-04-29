{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.gui.enable {
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        librewolf
        zen
      '';
      mode = "0755";
    };
  };

  xdg = {
    # make dark theme work notably
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    terminal-exec = {
      enable = true;
      settings.default = [
        "Alacritty.desktop"
      ];
    };
  };

  environment.systemPackages = [ pkgs.gparted ];
}
