{
  config,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "lock";
  bashOptions = [ ];
  runtimeInputs =
    with pkgs;
    [ procps ]
    ++ (
      if config.me.wm.displayServer == "wayland" then
        [ hyprlock ]
      else
        [
          i3lock-color
          xorg.xrdb
          xorg.xrefresh
        ]
    );
  text =
    let
      inherit (config.me.wm) browser;
    in
    # bash
    ''
      browser_was_open=false
      pgrep -x ${browser} > /dev/null && browser_was_open=true
      pkill -x ${browser} || true

      do_hibernate() {
        systemctl hibernate
        [[ $XDG_SESSION_TYPE == "x11" ]] && xrefresh
      }

      ( sleep 300 && do_hibernate ) &
      HIBERNATE_PID=$!

      if grep -q "closed" /proc/acpi/button/lid/*/state 2> /dev/null; then
        do_hibernate
      fi
        

      if [[ $XDG_SESSION_TYPE == "x11" ]]; then
        xget() {
          xrdb -query | grep "$1:" | cut -f2 | tr -d '#'
        }

        bg=$(xget "bg0")
        fg=$(xget "fg0")
        yellow=$(xget "yellow")
        red=$(xget "red")

        i3lock -n --indicator --color="''${bg}"ff \
            --inside-color="''${bg}"ff --ring-color="''${fg}"ff --line-uses-inside \
            --greeter-text="~locked" --greeter-pos="w/2:50" --greeter-color="''${fg}" \
            --greeter-font="Mononoki Nerd Font" --greeter-size=24 \
            --separator-color="''${fg}"ff --keyhl-color="''${bg}"ff --bshl-color="''${red}"ff \
            --insidever-color="''${yellow}"ff --insidewrong-color="''${red}"ff \
            --ringver-color="''${fg}"ff --ringwrong-color="''${fg}"ff --radius=60 \
            --verif-text="" --wrong-text="" --noinput-text="" --lock-text="" || i3lock -n
      else
        hyprlock
      fi

      kill "$HIBERNATE_PID" 2>/dev/null || true
      $browser_was_open && ${browser} &
    '';
}
