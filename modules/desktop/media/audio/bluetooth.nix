{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      persist.directories = [ "/var/lib/bluetooth" ];

      packages = [ pkgs.adw-bluetooth ];

      hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            MultiProfile = "multiple";
            Privacy = "device";
            FastConnectable = true;
          };
        };
      };
    };
}
