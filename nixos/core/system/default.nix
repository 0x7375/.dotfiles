{
  lib,
  options,
  pkgs,
  myLib,
  ...
}:

{
  i18n.supportedLocales = options.i18n.supportedLocales.default ++ [ "fr_FR.UTF-8/UTF-8" ];
  location.provider = "manual";

  hardware.i2c.enable = true;

  documentation.man.generateCaches = true;
  documentation.dev.enable = true;

  boot.tmp.useTmpfs = true;
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  zramSwap = {
    enable = true;
    memoryPercent = lib.mkDefault 25;
  };

  services.fstrim.enable = true;

  console = {
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132b.psf.gz";
    useXkbConfig = true;
    colors =
      let
        hex = myLib.hex;
      in
      [
        "000000"
        hex.red
        hex.green
        hex.yellow
        hex.blue
        hex.magenta
        hex.cyan
        "ffffff"
        hex.bg3
        hex.red
        hex.green
        hex.magenta
        hex.blue
        hex.magenta
        hex.cyan
        "ffffff"
      ];
  };

  time.timeZone = "Europe/Paris";
}
