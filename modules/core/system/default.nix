{
  flake.nixos.core =
    {
      pkgs,
      config,
      options,
      ...
    }:
    {
      i18n.supportedLocales = options.i18n.supportedLocales.default ++ [ "fr_FR.UTF-8/UTF-8" ];
      location.provider = "manual";

      boot.tmp.useTmpfs = true;
      systemd.services.nix-daemon = {
        environment.TMPDIR = "/var/tmp";
      };

      systemd.coredump.enable = false;
      boot.kernel.sysctl."kernel.core_pattern" = "|/bin/false";

      zramSwap = {
        enable = true;
        memoryPercent = 50;
      };

      services.fstrim.enable = true;
      services.earlyoom.enable = true;

      console = {
        earlySetup = true;
        packages = with pkgs; [ terminus_font ];
        font = "${pkgs.terminus_font}/share/consolefonts/ter-132b.psf.gz";
        useXkbConfig = true;
        # colors =
        #   let
        #     palette = config.me.hex.dark;
        #   in
        #   [
        #     "000000"
        #     palette.red
        #     palette.green
        #     palette.yellow
        #     palette.blue
        #     palette.magenta
        #     palette.cyan
        #     "ffffff"
        #     palette.bg3
        #     palette.red
        #     palette.green
        #     palette.magenta
        #     palette.blue
        #     palette.magenta
        #     palette.cyan
        #     "ffffff"
        #   ];
      };

      time.timeZone = "Europe/Paris";
    };
}
