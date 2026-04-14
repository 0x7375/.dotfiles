pkgs:
pkgs.writeShellApplication {
  name = "screenshot";
  runtimeInputs = with pkgs; [
    coreutils
    xdg-user-dirs
    libnotify
    grim
    slurp
    wl-clipboard-rs
    xdg-utils
  ];
  text = ''
    time=$(date -u "+%s" | cut -c 7-)
    file="Screenshot-$(date -u +%d-%m-%Y-"$time").png"
    folder="$(xdg-user-dir SCREENSHOTS)/"
    filepath="$folder$file"

    [[ -z "$1" ]] && exit 1

    active_mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1}')

    case "$1" in
      region)
        grim -g "$(slurp)" "$filepath"
        ;;
      monitor)
        grim -o "$active_mon" "$filepath"
        ;;
      window)
        geom=$(mmsg -g -x | awk -v mon="$active_mon" '
          $1 == mon { geo[$2] = $3 } 
          END { printf "%s,%s %sx%s\n", geo["x"], geo["y"], geo["width"], geo["height"] }
        ')
        grim -g "$geom" "$filepath"
        ;;
      *)
        echo "Usage: screenshot {region|window|monitor}"
        exit 1
        ;;
    esac

    wl-copy < "$filepath"

    (
     action=$(notify-send -i "$filepath" "Screenshot saved" "$filepath" --action="open=open")
     [[ "$action" == "open" ]] && xdg-open "$filepath"
    ) &
  '';
}
