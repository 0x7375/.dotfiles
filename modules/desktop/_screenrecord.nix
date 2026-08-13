pkgs:
pkgs.writeShellApplication {
  name = "screenrecord";
  runtimeInputs = with pkgs; [
    coreutils
    xdg-user-dirs
    libnotify
    wf-recorder
    slurp
    wl-clipboard
    xdg-utils
    ffmpeg
    procps
  ];
  excludeShellChecks = [ "SC2012" ];
  bashOptions = [ ];
  text =
    let
      inherit (pkgs.lib) getExe;
    in
    # bash
    ''
      if pgrep -x "wf-recorder" >/dev/null; then
        filepath=$(ls -t "$(xdg-user-dir VIDEOS)"/* | head -1)

        pkill -INT -x wf-recorder
        sleep 1

        echo -n "file://$filepath" | wl-copy -t text/uri-list

        thumb="/tmp/thumb.png"
        ffmpeg -y -i "$filepath" -vframes 1 "$thumb" 2>/dev/null

        action=$(notify-send -i "$thumb" "Recording Saved" "$filepath" --action="open=open")
        [[ "$action" == "open" ]] && xdg-open "$filepath"
        rm -f "$thumb"

        exit 0
      fi

      mode=$(printf "region\nmonitor\nwindow" | ${getExe pkgs.noctalia} dmenu -p "Recording scope..." -g app-window)
      [[ -z "$mode" ]] && exit 0

      audio_list=$(wpctl status | awk '/\[vol:/ { sub(/.*│[ *]*/, ""); sub(/ *\[vol:.*/, ""); sub(/\. /, " "); print }')
      no_audio="No audio"
      audio_choice=$(printf "$no_audio\n%s" "$audio_list" | ${getExe pkgs.noctalia} dmenu -p "Audio to capture...")
      [[ -z "$audio_choice" ]] && exit 0

      audio_flag=""
      if [[ "$audio_choice" != "$no_audio" ]]; then
        audio_id=$(echo "$audio_choice" | awk '{print $1}')
        audio_flag="--audio-backend=pipewire -a $audio_id"
      fi

      time=$(date -u "+%s" | cut -c 7-)
      file="Record-$(date -u +%d-%m-%Y-"$time").mp4"
      folder="$(xdg-user-dir VIDEOS)/"
      filepath="$folder$file"

      active_mon=$(mmsg get focusing-client | jq .monitor)
      enc_opts="$audio_flag -x yuv420p -c h264_nvenc -p preset=p7 -p tune=hq -p cq=20 -p b=0"

      case "$mode" in
        region)
          geom=$(slurp)
          [[ -z "$geom" ]] && exit 1
          record_cmd="wf-recorder -g \"$geom\" -f \"$filepath\" $enc_opts"
          ;;
        monitor)
          record_cmd="wf-recorder -o \"$active_mon\" -f \"$filepath\" $enc_opts"
          ;;
        window)
          geom=$(mmsg get monitor "$active_mon" | jq -r '"\(.x),\(.y) \(.width)x\(.height)"')
          record_cmd="wf-recorder -g \"$geom\" -f \"$filepath\" $enc_opts"
          ;;
        *)
          exit 1
          ;;
      esac

      ${getExe pkgs.my.notify} -i video "Recording Started" "Mode: $mode" -t 2000

      eval "$record_cmd"
    '';
}
