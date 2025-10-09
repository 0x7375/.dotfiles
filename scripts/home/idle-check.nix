{ pkgs, config, ... }:
pkgs.writeShellApplication {
  name = "idle-check";
  runtimeInputs =
    with pkgs;
    [
      systemd
      scripts.lock
    ]
    ++ (
      if config.me.gui.displayServer == "wayland" then
        [ hyprland ]
      else
        [
          xorg.xrandr
          xorg.xset
        ]
    );
  bashOptions = [
    "nounset"
    "pipefail"
  ];
  text = ''
    # ignore standby and suspend when connected to a monitor
    if [[ $XDG_SESSION_TYPE == "x11" ]]; then
      external_monitor_connected=$(xrandr --query | grep -w "connected" | grep -v "eDP")
    else
      external_monitor_connected=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name != "eDP-1") | .name' | head -n1)
    fi

    case $1 in
      "standby")
        [[ -n $external_monitor_connected ]] && exit 0

        if [[ $XDG_SESSION_TYPE == "x11" ]]; then
          xset dpms force standby
        else
          hyprctl dispatch dpms off
        fi
        ;;
      "lock") pidof lock || lock ;;
      "hibernate") systemctl hibernate ;;
    esac
  '';
}
