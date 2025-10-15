{
  config,
  myLib,
  pkgs,
  ...
}:
let
  inherit (myLib) palette light_palette;
in
pkgs.writeShellApplication {
  name = "generate-icons";
  runtimeInputs = with pkgs; [
    procps
    coreutils
    imagemagick
    dunst
  ];
  text = ''
    icons_dir="${config.me.flakeDir}/assets/dunst/output"
    source_dir="${config.me.flakeDir}/assets/dunst/source"

    mkdir -p "$icons_dir"

    primary=${palette.fg0}
    green=${palette.green}
    red=${palette.red}
    light_primary=${light_palette.fg0}
    light_green=${light_palette.green}
    light_red=${light_palette.red}

    rm -f "$icons_dir"/*

    for file in "$source_dir"/*.png; do
      filename=$(basename -- "$file")
      base_name="''${filename%.png}"
      
      case "$filename" in
        battery-full.png)
          dark_color="$green"
          light_color="$light_green"
          ;;
        battery-low.png)
          dark_color="$red"
          light_color="$light_red"
          ;;
        *)
          dark_color="$primary"
          light_color="$light_primary"
          ;;
      esac
      
      magick "$file" -fill "$dark_color" -colorize 100% "$icons_dir/$base_name-dark.png"
      magick "$file" -fill "$light_color" -colorize 100% "$icons_dir/$base_name-light.png"
    done

    dunstctl reload
  '';
}
