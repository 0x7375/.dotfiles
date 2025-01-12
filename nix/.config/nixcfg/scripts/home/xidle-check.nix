{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "xidle-check";
  runtimeInputs = with pkgs; [
    systemd
    scripts.lock
    xorg.xrandr
    xorg.xset
  ];
  text = ''
    # ignore standby and suspend when connected to a monitor

    EXTERNAL_MONITOR_CONNECTED=$(xrandr --query | grep -w "connected" | grep -v "eDP")

    if [ -n "$EXTERNAL_MONITOR_CONNECTED" ]; then
      case $1 in
        "lock") lock ;;
      esac
    else
      case $1 in
        "standby") xset dpms force standby ;;
        "lock") lock ;;
        "hibernate") systemctl hibernate ;;
      esac
    fi
  '';
}
