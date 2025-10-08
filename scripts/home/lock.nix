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
      i3lock -e -n --indicator --color=${hex.bg0_dark} \
          --inside-color=${hex.bg0_dark}ff --ring-color=${hex.fg0}ff --line-uses-inside \
          --separator-color=${hex.fg0}ff --keyhl-color=${hex.bg0}ff --bshl-color=${hex.red}ff \
          --insidever-color=${hex.yellow}ff --insidewrong-color=${hex.red}ff \
          --ringver-color=${hex.fg0}ff --ringwrong-color=${hex.fg0}ff --radius=60 \
          --verif-text="" --wrong-text="" --noinput-text="" --lock-text=""
    else
      hyprlock
    fi

    if pgrep -x "1password" > /dev/null; then
      1password --lock
    fi
  '';
}
