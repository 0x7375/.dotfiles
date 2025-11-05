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
    terminal-exec = {
      enable = true;
      settings.default = [
        "foot.desktop"
        "Alacritty.desktop"
      ];
    };
  };

  packages = [ pkgs.gparted ];
}
