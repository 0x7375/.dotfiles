{
  config,
  myLib,
  pkgs,
  ...
}:

let
  hex = myLib.hex;
in
pkgs.writeShellApplication {
  name = "lock";
  runtimeInputs =
    with pkgs;
    [
      procps
      _1password-cli
    ]
    ++ (
      if config.me.gui.displayServer == "wayland" then
        [
          hyprlock
        ]
      else
        [
          i3lock-color
        ]
    );
  text = ''
    if [[ $XDG_SESSION_TYPE == "x11" ]]; then
      xget() {
        xrdb -query | grep "$1:" | cut -f2 | tr -d '#'
      }

      bg=$(xget "bg0")
      fg=$(xget "fg0")
      yellow=$(xget "yellow")
      red=$(xget "red")

      i3lock -e -n --indicator --color="''${bg}"ff \
          --inside-color="''${bg}"ff --ring-color="''${fg}"ff --line-uses-inside \
          --greeter-text="~locked" --greeter-pos="w/2:50" --greeter-color="''${fg}" \
          --greeter-font="Mononoki Nerd Font" --greeter-size=24 \
          --separator-color="''${fg}"ff --keyhl-color="''${bg}"ff --bshl-color="''${red}"ff \
          --insidever-color="''${yellow}"ff --insidewrong-color="''${red}"ff \
          --ringver-color="''${fg}"ff --ringwrong-color="''${fg}"ff --radius=60 \
          --verif-text="" --wrong-text="" --noinput-text="" --lock-text=""
    else
      hyprlock
    fi

    if pgrep -x "1password" > /dev/null; then
      1password --lock
    fi
  '';
}
