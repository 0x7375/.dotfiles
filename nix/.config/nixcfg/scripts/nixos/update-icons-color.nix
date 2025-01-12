{
  config,
  myLib,
  pkgs,
  ...
}:

let
  palette = myLib.palette;
in
pkgs.writeShellApplication {
  name = "update-icons-color";
  runtimeInputs = with pkgs; [
    procps
    coreutils
    imagemagick
  ];
  text = ''
    ICONS_DIR="${config.me.flakeDir}/assets/dunst"
    OLD_ICONS_DIR="$ICONS_DIR/icons.old"

    # Colors
    PRIMARY=${palette.fg0}
    GREEN=${palette.green}
    RED=${palette.red}

    mkdir -p $OLD_ICONS_DIR
    mv "$ICONS_DIR"/*.png "$OLD_ICONS_DIR"

    recolor_icons() {
      local filename="$1"
      local color="$2"
      convert "$OLD_ICONS_DIR/$filename" -fill "$color" -colorize 100% "$ICONS_DIR/$filename"
    }

    for file in "$OLD_ICONS_DIR"/*; do
      filename=$(basename -- "$file")

      case "$filename" in
        battery-full.png)
          recolor_icons "$filename" "$GREEN"
          ;;
        battery-low.png)
          recolor_icons "$filename" "$RED"
          ;;
        *)
          recolor_icons "$filename" "$PRIMARY"
          ;;
        esac
    done
    pkill dunst
  '';
}
