{
  flake.modules.nixos.boot =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.me =
        let
          inherit (lib) types mkEnableOption mkOption;
          cfg = config.me.boot;
        in
        {
          boot = {
            silent.enable = mkOption {
              type = types.bool;
              default = !cfg.debug.enable;
              description = "Enable silent boot";
            };
            debug.enable = mkEnableOption "Make boot verbose";
            encryption.enable = mkEnableOption "Make boot verbose";
            secureBoot.enable = mkEnableOption "Enable secure boot";
          };
        };

      config = lib.mkMerge [
        {
          boot.plymouth = {
            enable = true;
            theme = "spinner_alt";
            themePackages = [
              (pkgs.adi1090x-plymouth-themes.override {
                selected_themes = [ "spinner_alt" ];
              })
            ];
          };

          systemd.ctrlAltDelUnit = "poweroff.target";

          boot.kernel.sysctl."kernel.sysrq" = 1;

          systemd.settings.Manager.RebootWatchdogSec = "10s";

          boot.initrd.systemd.enable = true;

          boot.loader.limine = {
            enable = true;
            enableEditor = false;
            maxGenerations = 30;
            # TODO: watch nixpkgs issues about automating keys enrolling
            secureBoot.enable = config.me.boot.secureBoot.enable;
            style = {
              backdrop = "000000";
              wallpapers = lib.mkForce [ ];

              interface = {
                helpHidden = true;
                branding = "";
              };

              graphicalTerminal = {
                background = "FF000000";
                foreground = "FFFFFF";
              };
            };
            extraConfig = ''
              quiet: yes
            '';
          };
          boot.loader.timeout = 1;
        }
        (lib.mkIf config.me.boot.silent.enable {
          boot.kernelParams = [
            "quiet"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
          ];

          boot.consoleLogLevel = lib.mkForce 0; # forcing because disko sets this
          boot.initrd.verbose = false;
        })
        (lib.mkIf config.me.boot.debug.enable {
          boot.plymouth.enable = lib.mkForce false;

          boot.kernelParams = [
            "systemd.show_status=true"
            "systemd.log_level=debug"
            "systemd.log_target=kmsg"
            "log_buf_len=1M"
          ];
        })
        (lib.mkIf config.me.boot.encryption.enable {
          # don't fail when a password is entered while the key isn't plugged in
          boot.initrd.systemd.services."systemd-cryptsetup@crypted" = {
            overrideStrategy = "asDropin";
            serviceConfig = {
              ExecStart = lib.mkForce [
                ""
                "/bin/sh -c 'while ! /bin/systemd-cryptsetup attach crypted ${config.boot.initrd.luks.devices.crypted.device} - fido2-device=auto,token-timeout=0; do rm -f /run/systemd/ask-password/*; sleep 1; done'"
              ];
            };
          };

          boot.initrd.luks.devices.crypted.crypttabExtraOpts = [
            "fido2-device=auto"
            "token-timeout=0"
          ];

          # prevent luks pw prompt from timing out
          boot.initrd.systemd.settings.Manager.DefaultDeviceTimeoutSec = "infinity";
        })
      ];
    };
}
