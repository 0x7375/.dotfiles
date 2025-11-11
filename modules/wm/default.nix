{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable {
  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [
        "foot.desktop"
        "Alacritty.desktop"
      ];
    };
  };

  system.userActivationScripts.generateDunstIcons.text = lib.getExe pkgs.scripts.generate-icons;
  services.dbus.enable = true;
}
