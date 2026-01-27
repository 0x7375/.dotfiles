{
  lib,
  config,
  mkNixos,
  pkgs,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  packages = [ pkgs.blueberry ];

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
})
