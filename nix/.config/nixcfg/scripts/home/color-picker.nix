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
          (myLib.fromRoot "assets/patches/xcolor_cancel_with_right_click.patch")
        ];
      });
    in
    [
      coreutils-full
      xcolor
      xsel
      hyprpicker
      libnotify
      imagemagick
    ]
    ++ lib.optionals config.wayland.windowManager.hyprland.enable [
      hyprpicker
    ];
  text = ''
    size="80x80"

    if [[ $XDG_SESSION_TYPE == "x11" ]]; then
      color=$(xcolor | tr -d '\n')
      [[ $color = "" ]] || {
        echo -n "$color" | xsel -ib
        convert -size "$size" xc:"$color" /tmp/color.png
        notify-send --icon "/tmp/color.png" "Copied $color to clipboard"
      }
    else
      color=$(hyprpicker -ra)
      convert -size "$size" xc:"$color" /tmp/color.png
      notify-send --icon "/tmp/color.png" "Copied $color to clipboard"
    fi
  '';
}
