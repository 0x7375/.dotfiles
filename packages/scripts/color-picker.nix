{
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "color-picker";
  runtimeInputs = with pkgs; [
    coreutils-full
    libnotify
    imagemagick
    hyprpicker
  ];
  text = ''
    size="80x80"
    color=$(hyprpicker -ra) && {
      notify-send --icon "/tmp/color.png" "Copied $color to clipboard"
      convert -size "$size" xc:"$color" /tmp/color.png
    }
  '';
}
