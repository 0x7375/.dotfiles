{
  pkgs,
  config,
  lib,
  mkNixos,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [
        "foot.desktop"
        "Alacritty.desktop"
      ];
    };
  };

  activation = lib.getExe pkgs.my.generate-icons;
  services.dbus.enable = true;
})
