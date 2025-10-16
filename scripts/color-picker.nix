{
  myLib,
  config,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "color-picker";
  runtimeInputs =
    with pkgs;
    let
      xcolor = pkgs.xcolor.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./xcolor_cancel_with_right_click.patch
        ];
      });
    in
    [
      coreutils-full
      libnotify
      imagemagick
    ]
    ++ (
      if config.me.gui.displayServer == "wayland" then
        [
          hyprpicker
        ]
      else
        [
          xcolor
          xsel
        ]
    );
  text = ''
    size="80x80"
    color=

    if [[ $XDG_SESSION_TYPE == "x11" ]]; then
      color=$(xcolor | tr -d '\n')
      [[ -n $color ]] && {
        echo -n "$color" | xsel -ib
      }
    else
      color=$(hyprpicker -ra)
    fi && {
      notify-send --icon "/tmp/color.png" "Copied $color to clipboard"
      convert -size "$size" xc:"$color" /tmp/color.png
    }
  '';
}
