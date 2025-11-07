{
  config,
  myLib,
  pkgs,
  ...
}:
let
  inherit (myLib.palette) dark light;
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

    rm -rf "$icons_dir"
    mkdir -p "$icons_dir/dark" "$icons_dir/light"

    primary=${dark.fg0}
    green=${dark.green}
    red=${dark.red}
    light_primary=${light.fg0}
    light_green=${light.green}
    light_red=${light.red}

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
      
      magick "$file" -fill "$dark_color" -colorize 100% "$icons_dir/dark/$base_name.png"
      magick "$file" -fill "$light_color" -colorize 100% "$icons_dir/light/$base_name.png"
    done

    dunstctl reload
  '';
}
