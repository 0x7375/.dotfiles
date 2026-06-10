{
  flake.modules.nixos.desktop =
    {
      lib,
      pkgs,
      ...
    }:
    lib.mkMerge [
      {
        # systemd.user.services.devmon = {
        #   path = [ pkgs.libnotify ];
        #   serviceConfig.ExecStart =
        #     let
        #       mount = "/run/media/ayko";
        #     in
        #     lib.mkForce ''${lib.getExe' pkgs.udevil "devmon"} --exec-on-remove "notify-send 'Device %f unmounted from ${mount}' -i disk -r 9998" --exec-on-drive "notify-send 'Device %f mounted at ${mount}' -i disk -r 9999"'';
        # };

        services = {
          # devmon.enable = true;

          ddccontrol.enable = true; # external monitor brightness control

          libinput = {
            mouse = {
              accelProfile = "flat";
              accelSpeed = "0";
            };
            enable = true;
          };
        };

        # passes 8bitdo controller as regular xbox controller
        services.udev.extraRules = # bash
          ''
            ACTION=="add", \
            ATTRS{idVendor}=="2dc8", \
            ATTRS{idProduct}=="3109", \
            RUN+="${lib.getExe' pkgs.kmod "modprobe"} xpad", \
            RUN+="/bin/sh -c 'echo 2dc8 3109 > /sys/bus/usb/drivers/xpad/new_id'"
          '';

        hardware.keyboard.qmk.enable = true;
      }
      (lib.mkIf (!pkgs.stdenv.isAarch64) {
        packages = with pkgs; [ vial ];
        services.udev.packages = with pkgs; [ vial ];
      })
    ];
}
