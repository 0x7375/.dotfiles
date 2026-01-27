{
  config,
  lib,
  pkgs,
  mkNixos,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  unfree-packages = [
    "hplip"
  ];

  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  hardware.printers = {
    ensureDefaultPrinter = "HP_DeskJet_4200";
    ensurePrinters = [
      {
        name = "HP_DeskJet_4200";
        deviceUri = "dnssd://HP%20DeskJet%204200%20series%20%5B96A077%5D._ipp._tcp.local/?uuid=8a091d9d-3e08-46c4-ac0a-3a60f9b12523";
        model = "HP/hp-Deskjet_4200_series.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
          ColorModel = "Color";
        };
      }
    ];
  };
})

