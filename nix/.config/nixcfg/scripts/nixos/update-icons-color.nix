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
    icons_dir="${config.me.flakeDir}/assets/dunst"
    old_icons_dir="$icons_dir/icons.old"

    primary=${palette.fg0}
    green=${palette.green}
    red=${palette.red}

    mkdir -p $old_icons_dir
    mv "$icons_dir"/*.png "$old_icons_dir"

    recolor_icons() {
      local -r filename="$1"
      local -r color="$2"
      convert "$old_icons_dir/$filename" -fill "$color" -colorize 100% "$icons_dir/$filename"
    }

    for file in "$old_icons_dir"/*; do
      filename=$(basename -- "$file")

      case "$filename" in
        battery-full.png)
          recolor_icons "$filename" "$green"
          ;;
        battery-low.png)
          recolor_icons "$filename" "$red"
          ;;
        *)
          recolor_icons "$filename" "$primary"
          ;;
        esac
    done
    pkill dunst
  '';
}
