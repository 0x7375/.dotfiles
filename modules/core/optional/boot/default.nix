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

    boot.initrd.luks.devices.crypted.crypttabExtraOpts = [ "fido2-device=auto" ];

    boot.initrd.systemd.enable = true;

    environment.etc.temp.text = "rebuild";

    boot.loader.limine = {
      enable = true;
      enableEditor = false;
      maxGenerations = 30;
      # TODO: watch nixpkgs issues about automating keys enrolling
      secureBoot.enable = true;
      style = {
        backdrop = "000000";
        wallpapers = lib.mkForce [ ];

        # TODO: uncomment on next update
        interface = {
          # helpHidden = true;
          branding = "";
        };

        graphicalTerminal = {
          background = "FF000000";
          foreground = "FFFFFF";
        };
      };
      extraConfig = ''
        # TODO: remove on next update
        interface_help_hidden: yes
        quiet: yes
      '';
    };
    boot.loader.timeout = 1;

    boot.loader.efi.canTouchEfiVariables = true;
  });
}
