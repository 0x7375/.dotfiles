{
  options,
  pkgs,
  myLib,
  ...
}:

{
  i18n.supportedLocales = options.i18n.supportedLocales.default ++ [ "fr_FR.UTF-8/UTF-8" ];

  hardware.i2c.enable = true;

  boot.tmp.cleanOnBoot = true;

  console = {
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
