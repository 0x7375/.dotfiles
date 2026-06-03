pkgs:
pkgs.writeShellApplication {
  name = "screenshot";
  runtimeInputs = with pkgs; [
    coreutils
    xdg-user-dirs
    libnotify
    grim
    slurp
    wl-clipboard
    xdg-utils
  ];
  text = ''
    time=$(date -u "+%s" | cut -c 7-)
    file="Screenshot-$(date -u +%d-%m-%Y-"$time").png"
    folder="$(xdg-user-dir SCREENSHOTS)/"
    filepath="$folder$file"

    [[ -z "$1" ]] && exit 1

    active_mon=$(mmsg get focusing-client | jq .monitor)

    case "$1" in
      region)
        grim -g "$(slurp)" "$filepath"
        ;;
      monitor)
        grim -o "$active_mon" "$filepath"
        ;;
      window)
        geom=$(mmsg get monitor "$active_mon" | jq -r '"\(.x),\(.y) \(.width)x\(.height)"')
        grim -g "$geom" "$filepath"
        ;;
      *)
        echo "Usage: screenshot {region|window|monitor}"
        exit 1
        ;;
    esac

    wl-copy < "$filepath"

    (
     action=$(notify-send -i "$filepath" -a "Screenshot saved" "$filepath" --action="open=open")
     [[ "$action" == "open" ]] && xdg-open "$filepath"
    ) &
  '';
}
