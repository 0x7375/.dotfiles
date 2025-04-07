{ config, lib, ... }:

lib.mkIf config.me.gui.enable {
  services.pipewire = {
    enable = true;
    extraConfig.pipewire = {
      "99-disable-bell" = {
        "context.properties" = {
          "module.x11.bell" = false;
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
