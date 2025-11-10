{ config, lib, ... }:

lib.mkIf config.me.desktop.enable {
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    extraConfig.pipewire = {
      "99-custom" = {
        "context.properties" = {
          "module.x11.bell" = false;
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 1024;
        };
      };
    };
  };

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
}
