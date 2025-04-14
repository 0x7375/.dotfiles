{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "dofus-travel";
  runtimeInputs = with pkgs; [
    xdotool
    wmctrl
  ];
  text = ''
    window_id=$(wmctrl -l | grep " Dofus$" | cut -d' ' -f1)

    sleep 0.4

    # focus dofus window
    wmctrl -i -a "$window_id"

    sleep 0.2

    xdotool key space

    sleep 0.1

    xdotool key ctrl+v

    sleep 0.1

    xdotool key Return
    sleep 0.2
    xdotool key Return

    sleep 0.3

    eval "$(xdotool getwindowgeometry --shell "$window_id")"

    # move mouse to bottom right corner to lose chat focus
    xdotool mousemove --window "$window_id" $(("$WIDTH" - 2)) $((2)) click 1

    sleep 0.3

    # move back near marker icons
    # *******************
    # *                 *
    # * +               *
    # *                 *
    # *                 *
    # *******************
    xdotool mousemove --window "$window_id" $(("$WIDTH" / 6)) $(("$HEIGHT" / 3))
  '';
}
