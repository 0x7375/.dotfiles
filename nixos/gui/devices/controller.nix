{ lib, pkgs, ... }:

{
  # passes 8bitdo controller as regular xbox controller
  services.udev.extraRules = # bash
    ''
      ACTION=="add", \
      ATTRS{idVendor}=="2dc8", \
      ATTRS{idProduct}=="3109", \
      RUN+="${lib.getExe' pkgs.kmod "modprobe"} xpad", \
      RUN+="/bin/sh -c 'echo 2dc8 3109 > /sys/bus/usb/drivers/xpad/new_id'"
    '';
}
