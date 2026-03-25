{
  flake.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      packages = [ pkgs.adw-bluetooth ];

      hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            MultiProfile = "multiple";
            Privacy = "device";
            FastConnectable = true;
            Enable = "Control,Gateway,Headset,Media,Sink,Socket,Source";
            # Uncomment on first connection airpods
            # ControllerMode = "bredr";
          };
        };
      };
    };
}
