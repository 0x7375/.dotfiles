{
  flake.modules.nixos.core =
    {
      pkgs,
      options,
      config,
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

      boot.kernelPackages = pkgs.linuxPackages_latest;

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
        colors =
          let
            p = config.tinted.hex.dark;
          in
          [
            "000000"
            p.red
            p.green
            p.yellow
            p.blue
            p.magenta
            p.cyan
            "ffffff"
            p.bg3
            p.red
            p.green
            p.magenta
            p.blue
            p.magenta
            p.cyan
            "ffffff"
          ];
      };

      time.timeZone = "Europe/Paris";
    };
}
