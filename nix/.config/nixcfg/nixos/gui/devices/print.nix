{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  hardware.printers = {
    ensureDefaultPrinter = "HP_ENVY_4500";
    ensurePrinters = [
      {
        name = "HP_ENVY_4500";
        deviceUri = "dnssd://HP%20ENVY%204500%20series%20%5B9EF674%5D._ipp._tcp.local/?uuid=1c852a4d-b800-1f08-abcd-a45d369ef674";
        model = "HP/hp-envy_4500_series.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
          ColorModel = "Color";
        };
      }
    ];
  };
}
