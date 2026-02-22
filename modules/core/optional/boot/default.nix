{
  pkgs,
  lib,
  config,
  mkNixos,
  ...
}:

let
  cfg = config.me.boot;
in
{
  options.me =
    let
      inherit (lib) types mkEnableOption mkOption;
    in
    {
      boot = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Setup systemd boot with plymouth";
        };
        silent.enable = mkOption {
          type = types.bool;
          default = (!cfg.debug.enable && cfg.enable);
          description = "Enable silent boot";
        };
        debug.enable = mkEnableOption "Make boot verbose";
      };
    };

  config = lib.mkIf cfg.enable (mkNixos {
    boot.plymouth = {
      enable = true;
      theme = "spinner_alt";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "spinner_alt" ];
        })
      ];
    };

    boot.kernel.sysctl."kernel.sysrq" = 1;

    systemd.settings.Manager.RebootWatchdogSec = "10s";

    boot.initrd.systemd.enable = true;
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.editor = false;
    boot.loader.systemd-boot.configurationLimit = 30;
    boot.loader.timeout = 0;
    boot.loader.efi.canTouchEfiVariables = true;
  });
}
