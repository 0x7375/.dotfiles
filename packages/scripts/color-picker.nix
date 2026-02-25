{
  config,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "color-picker";
  runtimeInputs =
    with pkgs;
    let
    in
    [
      coreutils-full
      libnotify
      imagemagick
    ]
    ++ (
      if config.me.wm.displayServer == "wayland" then
        [
          hyprpicker
        ]
      else
        [
          xcolor
        ]
    );
  text = ''
    size="80x80"
    color=

    if [[ $XDG_SESSION_TYPE == "x11" ]]; then
      color=$(xcolor | tr -d '\n')
      [[ -n $color ]] && {
        echo -n "$color" | ${config.me.wm.copy}
      }
    else
      color=$(hyprpicker -ra)
    fi && {
      notify-send --icon "/tmp/color.png" "Copied $color to clipboard"
      convert -size "$size" xc:"$color" /tmp/color.png
    }
  '';
}
