{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.boot.enable {
  boot.plymouth = {
    enable = true;
    theme = "spinner_alt";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [ "spinner_alt" ];
      })
    ];
  };

  systemd.watchdog.rebootTime = "10s";

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 30;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
}
